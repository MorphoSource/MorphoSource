# For use with Down::ChunkedIO created by Down.open(uri)

module IntervalResponse
  class ChunkedIORackBodyWrapper < RackBodyWrapper
    def each
      buf = String.new(capacity: @chunk_size)
      @interval_response.each do |segment, range_in_segment|
        case segment
        when IntervalResponse::LazyFile
          segment.with do |file_handle|
            with_each_chunk(range_in_segment) do |offset, read_n|
              file_handle.seek(offset, IO::SEEK_SET)
              yield file_handle.read(read_n, buf)
            end
          end
        when String
          with_each_chunk(range_in_segment) do |offset, read_n|
            yield segment.slice(offset, read_n)
          end
        when IO, Tempfile, Down::ChunkedIO
          with_each_chunk(range_in_segment) do |offset, read_n|
            segment.seek(offset, IO::SEEK_SET)
            yield segment.read(read_n, buf)
          end
        else
          raise TypeError, "RackBodyWrapper only supports IOs or Strings"
        end
      end
    ensure
      buf.clear
    end
  end
end