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
          text_box id: :text_box2, size: {490, 30}
        end
        box :horizontal do
          text_box id: :text_box1, size: {490, 200}, multiline: true
        end
      end
    end
    Lab2.initialize
    pid = WindowProcess.spawn_gui f
    infinite_loop pid
  end

  def infinite_loop pid do
    reaction pid
    infinite_loop pid
  end

  defp reaction pid do
    continue = true
    receive_event do
      from pid: ^pid do
        from widget: :button1 do
          :click ->
            db = Lab2.print_data
            send pid, :text_box1, :set_value, db
        end
        from widget: :button2 do
          :click ->
            phrase = send pid, :text_box2, :get_value
            res = phrase |> Lab2.process_phrase |> Lab2.print_process_phrase_output
            send pid, :text_box1, :set_value, res
        end
      end
    end
  end
end
