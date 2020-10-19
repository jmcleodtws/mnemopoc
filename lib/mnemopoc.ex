defmodule MnemoPoc do

  @valid_strengths [128, 160, 192, 224, 256, 512]
  @default_strength 256

  def gen_mnemonic(strength \\ @default_strength) when strength in @valid_strengths do
    strength
    |> div(8)
    |> :crypto.strong_rand_bytes()
    |> mnemonic()
  end

  def mnemonic(entropy) do
    entropy
    |> maybe_decode()
    |> update_with_checksum()
    |> Mnemo.sentence()
    |> Enum.map(&Mnemo.word/1)
    |> Enum.join(" ")
  end

  defp update_with_checksum(ent) do
    {checksum, checksum_size} = Mnemo.checksum(ent)
    <<ent::binary, checksum::size(checksum_size)>>
  end

  defp maybe_decode(ent) do
    ent =
      case Base.decode16(ent, case: :mixed) do
        :error -> ent
        {:ok, decoded} -> decoded
      end

    bit_size(ent) in @valid_strengths || raise "ENT must be #{inspect(@valid_strengths)} bits"
    ent
  end

end
