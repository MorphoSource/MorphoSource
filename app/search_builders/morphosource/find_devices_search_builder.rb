class Morphosource::FindDevicesSearchBuilder < Morphosource::FindWorksSearchBuilder
  def models
    [Device, DeviceResource]
  end
end