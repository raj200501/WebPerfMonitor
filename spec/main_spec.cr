require "./spec_helper"

describe WebPerfMonitor do
  it "runs the monitoring process" do
    expect { WebPerfMonitor.run }.to_not raise_error
  end
end
