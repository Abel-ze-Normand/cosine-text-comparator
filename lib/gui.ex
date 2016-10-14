defmodule Gui do
  import Seagull
  import Widget
  def start(_, _) do
    f = frame id: :main_frame, size: {500, 300}, title: "Frame title" do
      box :vertical do
        box :horizontal do
          button id: :button1, label: "Show DB", react: [:click]
          button id: :button2, label: "Compare phrase", react: [:click]
        end
        box :horizontal do
          text_box id: :text_box1, size: {490, 200}, multiline: true
        end
      end
    end
    Lab2.initialize
    WindowProcess.spawn_gui f
    infinite_loop
  end

  def infinite_loop do
    a = 2
    infinite_loop
  end

  defp reaction pid, _ do
    continue = true
    receive_event do
      from pid: ^pid do
        from widget: :button1 do
          :click ->
            db = Lab2
        end
      end
    end
  end
end
