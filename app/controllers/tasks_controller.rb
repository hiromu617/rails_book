class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :file_not_blunk, only: :import

  def index
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true).page(params[:page]).per(50)

    respond_to do |format|
      format.html
      format.csv { send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end
  end

  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def update
    @task.update!(task_params)
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を更新しました"
  end

  def destroy
    @task.destroy
    # head :no_content
  end

  def create
    @task = current_user.tasks.new(task_params)

    if params[:back].present?
      render :new
      return
    end

    if @task.save
      TaskMailer.creation_email(@task).deliver_now
      SampleJob.perform_later
      redirect_to @task, notice: "タスク「#{@task.name}」を登録しました"
    else
      render :new
    end
  end

  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end

  def import
    current_user.tasks.import(params[:file]) 
    redirect_to tasks_url, notice: "タスクを追加しました"
  end

  private

    def task_params
      params.require(:task).permit(:name, :description, :image)
    end

    def set_task
      @task = current_user.tasks.find(params[:id])
    end

    def file_not_blunk
      redirect_to tasks_url unless params[:file]
    end
end
