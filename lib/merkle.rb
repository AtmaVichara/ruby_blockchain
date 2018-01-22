require 'digest'

class MerkleTree

  def initialize(ids)
    @hashes = []
    store_hashed_ids(ids)
  end

  def store_hashed_ids(ids)
    @hashes << ids[-1] if ids.length % 2 != 0
    if ids.length > 1
      ids.each_slice(2) do |id|
        @hashes << Digest::SHA256.hexdigest(id.join)
      end
    end
  end

end
