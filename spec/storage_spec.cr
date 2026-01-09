require "./spec_helper.cr"

TestSuite.test("storage writes and reads reports") do
  output_dir = "tmp/spec-storage"
  Support::FileUtil.mkdir_p(output_dir)
  store = WebPerfMonitor::FileStore.new(output_dir)

  output = store.write("{\"ok\": true}", "2024-01-01T00:00:00Z")

  TestSuite.assert(Support::FileUtil.file_exists?(output.path))
  TestSuite.assert_includes(store.read_latest, "ok")
end
