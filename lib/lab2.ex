defmodule Lab2 do
  @files_range 1..5
  def start(_, _) do
    IO.puts "Indexing data..."
    {:ok, _db_pid} = initialize
    IO.puts "Texts indexed"
    {:ok, self}
  end

  def retrieve_db_data, do: Agent.get(:occurences_store, fn(state) -> state end)

  def initialize do
    contents = read_files
    each_word_count = count_all_each_words(contents)
    occurences = reduce_each_word_count_in_each_text(each_word_count)
    Agent.start_link(fn -> occurences end, name: :occurences_store)
  end

  def print_data do
    occurences = retrieve_db_data
    header = ["word"] ++ Enum.map(@files_range, &("text#{&1}"))
    TableRex.quick_render!(occurences, header, "count of matches")
  end

  def process_phrase(phrase) do
    word_frequences = count_each_words(phrase)
    db = retrieve_db_data
    Enum.reduce @files_range, %{}, fn(i, acc) ->
      curr_file_occ = get_file_occurences_at(db, i)
      measure = cond do
        keys_count(curr_file_occ) < keys_count(word_frequences) ->
          calc_equality_measure(curr_file_occ, word_frequences);
        true ->
          calc_equality_measure(word_frequences, curr_file_occ)
      end
      Map.update acc, "file#{i}", measure, fn(_x) -> measure end
    end
  end

  def read_files do
    files = @files_range |> Enum.map(&("text#{&1}"))
    for file_name <- files do
      {:ok, contents} = File.read('#{file_name}')
      contents
    end
  end

  def keys_count(map) do
    map |> Map.keys |> Enum.count
  end

  def calc_equality_measure(lesser_map, bigger_map) do
    numerator = Enum.reduce lesser_map, 0, fn({ k, _v }, acc) ->
      acc + Map.get(lesser_map, k, 0) * Map.get(bigger_map, k, 0)
    end
    denom1 = Enum.reduce lesser_map, 0, fn({ _k, v }, acc) -> acc + v * v end
    denom2 = Enum.reduce bigger_map, 0, fn({ _k, v }, acc) -> acc + v * v end
    numerator / :math.sqrt(denom1) / :math.sqrt(denom2)
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

  def get_file_occurences_at(table, file_num) when file_num >=1 and file_num <= 5 do
    Stream.map(table, fn(row) -> { Enum.at(row, 0), Enum.at(row, file_num) } end)
    |> Enum.reduce(%{}, fn({ name, count }, acc) -> Map.put(acc, name, count)  end)
  end

  def get_file_occurences(_table, _file_num), do: {:error, :badargs}
end
