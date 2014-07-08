After('@tempfile') do
  if @tempfile
    @tempfile.close
    @tempfile.unlink
  end
end
