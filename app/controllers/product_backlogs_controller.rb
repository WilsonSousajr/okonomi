# Product backlog do projeto (#5): recurso singular, no máximo um por projeto.
class ProductBacklogsController < ApplicationController
  include ProjectScoped

  before_action :set_product_backlog, only: %i[ edit update destroy ]

  def new
    @backlog = @project.backlogs.product.new(name: "Product backlog")
  end

  def create
    @backlog = @project.backlogs.product.new(backlog_params)

    if @backlog.save
      redirect_to @project, notice: "Product backlog criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @backlog.update(backlog_params)
      redirect_to @project, notice: "Product backlog atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @backlog.destroy!
    redirect_to @project, notice: "Product backlog excluído.", status: :see_other
  end

  private
    def set_product_backlog
      @backlog = @project.product_backlog or raise ActiveRecord::RecordNotFound
    end

    # kind is never taken from the form: this controller only handles the product backlog.
    def backlog_params
      params.expect(backlog: [ :name, :goal ])
    end
end
