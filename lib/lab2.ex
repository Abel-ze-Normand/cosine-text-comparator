defmodule Lab2 do
  @files_range 1..5

  def initialize do
    contents = read_files
    total_words_count = count_all_words(contents)
    each_word_count = count_all_each_words(contents)
    occurences = reduce_each_word_count_in_each_text(each_word_count)
    header = ["word"] ++ Enum.map(@files_range, &("text#{&1}"))
    TableRex.quick_render!(occurences, header, "count of matches")
    |> IO.puts
  end

  def read_files do
    files = @files_range |> Enum.map(&("text#{&1}"))
    for file_name <- files do
      {:ok, contents} = File.read('#{file_name}')
      contents
    end
  end

  def count_all_words(contents), do:  Enum.map contents, &count_words/1

  defp count_words(all_text) do
    String.split(all_text, [" ", ",", "\n", "-", "–", ".", ":", "\""], trim: true)
    |> Stream.filter(fn(word) -> String.length(word) >= 3 end)
    |> Stream.filter(fn(word) -> not Regex.match?(~r/\d/, word) end)
    |> Enum.count
  end

  def count_all_each_words(contents), do: Enum.map contents, &count_each_words/1

  def count_each_words(all_text) do
    String.split(all_text, [" ", ",", "\n", "-", "–", ".", ":", "\""], trim: true)
    |> Stream.filter(fn(word) -> String.length(word) >= 3 end)
    |> Stream.filter(fn(word) -> not Regex.match?(~r/\d/, word) end)
    |> Stream.map(fn(word) -> word |> String.downcase |> Stemex.russian end)
    |> Enum.reduce(%{}, fn(word, acc) -> Map.update(acc, word, 1, &(&1 + 1)) end)
  end

  defp reduce_each_word_count_in_each_text(list_of_maps) do
    all_words = collect_uniq_words(list_of_maps)
    occurences = Enum.map @files_range, fn(i) ->
      file_data = Enum.at(list_of_maps, i - 1)
      Enum.map all_words, fn(word) ->
        Map.get(file_data, word, 0)
      end
    end
    List.zip([all_words | occurences]) |> Enum.map(&Tuple.to_list/1)
  end

  defp collect_uniq_words(list_of_maps) do
    Enum.reduce(list_of_maps, [], fn(word_count_map, acc) -> acc ++ Map.keys(word_count_map) end)
    |> Enum.uniq
  end

  defp get_file_occurences(table, file_num) when file_num >=1 and file_num <= 5 do
    Stream.map(table, fn(row) -> { Enum.at(row, 0), Enum.at(row, file_num) } end)
    |> Enum.reduce(%{}, fn({ name, count }, acc) -> Map.put(acc, name, count)  end)
  end

  defp get_file_occurences(table, file_num), do: {:error, :badargs}
end
