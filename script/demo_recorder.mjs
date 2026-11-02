// Records the demo system test (#32) as a sequence of frames through the Chrome
// DevTools screencast, so the video shows the real browser in real time without a
// screen-recording permission. Usage: node script/demo_recorder.mjs <port> <out_dir>
// Stops on SIGINT/SIGTERM and writes <out_dir>/frames.txt for ffmpeg's concat demuxer.
import { mkdirSync, writeFileSync } from "node:fs"

const [port = "9333", outDir = "tmp/demo"] = process.argv.slice(2)
const framesDir = `${outDir}/frames`
mkdirSync(framesDir, { recursive: true })

const frames = []
let socket
let nextId = 1

const send = (method, params = {}) => socket.send(JSON.stringify({ id: nextId++, method, params }))

async function pageTarget() {
  for (;;) {
    try {
      const targets = await (await fetch(`http://127.0.0.1:${port}/json`)).json()
      const page = targets.find(target => target.type === "page" && target.webSocketDebuggerUrl)
      if (page) return page
    } catch {}
    await new Promise(resolve => setTimeout(resolve, 200))
  }
}

function finish() {
  // Each frame lasts until the next one; the last is held for two seconds.
  const lines = ["ffconcat version 1.0"]
  frames.forEach((frame, index) => {
    const next = frames[index + 1]
    lines.push(`file 'frames/${frame.file}'`, `duration ${next ? (next.time - frame.time).toFixed(3) : "2.000"}`)
  })
  if (frames.length) lines.push(`file 'frames/${frames.at(-1).file}'`)
  writeFileSync(`${outDir}/frames.txt`, lines.join("\n") + "\n")
  console.log(`demo_recorder: ${frames.length} frames`)
  process.exit(0)
}

process.on("SIGINT", finish)
process.on("SIGTERM", finish)

const target = await pageTarget()
socket = new WebSocket(target.webSocketDebuggerUrl)
socket.addEventListener("open", () => {
  send("Page.enable")
  send("Page.startScreencast", { format: "jpeg", quality: 90, maxWidth: 1920, maxHeight: 1200, everyNthFrame: 1 })
})
socket.addEventListener("message", ({ data }) => {
  const message = JSON.parse(data)
  if (message.method !== "Page.screencastFrame") return

  const { data: jpeg, metadata, sessionId } = message.params
  // Frames from before Capybara resizes the window would set a smaller video size.
  if (metadata.deviceWidth < 1000) return send("Page.screencastFrameAck", { sessionId })

  const file = `${String(frames.length).padStart(6, "0")}.jpg`
  writeFileSync(`${framesDir}/${file}`, Buffer.from(jpeg, "base64"))
  frames.push({ file, time: metadata.timestamp })
  send("Page.screencastFrameAck", { sessionId })
})
socket.addEventListener("close", finish)
