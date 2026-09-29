require "test_helper"

class DatabaseConfigTest < ActiveSupport::TestCase
  # libpq's GSSAPI negotiation deadlocks in forked workers on macOS, so the parallel
  # suite hung forever once it reached 50 tests (#52).
  test "test_gss_encryption_is_disabled_so_forked_workers_do_not_hang_issue_52" do
    assert_equal "disable", ActiveRecord::Base.connection_db_config.configuration_hash[:gssencmode]
  end
end
