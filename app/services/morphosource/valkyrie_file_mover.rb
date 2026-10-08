# frozen_string_literal: true
module Morphosource
  # VersionedDisk's file_mover (see config/initializers/valkyrie.rb). Mainly used in
  # FCRepo->Valkyrie migration. Whenever source and destination share a filesystem,
  # uses hard links (zero-copy, zero extra disk space). Falls back to a real
  # copy whenever that isn't possible, so it's safe in all cases -- including EPERM,
  # raised when the source belongs to another user (e.g. FCRepo's binaries on
  # deployed envs) and the kernel's protected_hardlinks setting forbids linking it.
  class ValkyrieFileMover
    def self.call(source, dest)
      File.link(source, dest)
    rescue Errno::EXDEV, Errno::ENOENT, Errno::EPERM, NotImplementedError
      FileUtils.cp(source, dest)
    end
  end
end
