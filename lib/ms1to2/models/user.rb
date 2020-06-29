module Ms1to2
  module Models
    class User < BaseObject
      class_attribute :class_control_vocab_mappings

      self.class_control_vocab_mappings = {
        :demographics => {
          'Student: K-6' => 'Student (Grades K-6)',
          'Student:7-12' => 'Student (Grades 7-12)',
          'Student: College/Post-Secondary ' => 'Student (University or Post-Secondary)',
          'Student: Graduate' => 'Student (Post-Graduate)',
          'Faculty: K-6' => 'Faculty (Grades K-6)',
          'Faculty:7-12' => 'Faculty (Grades K-7)',
          'Faculty College/Post-Secondary' => 'Faculty (University or Post-Secondary)',
          'Staff: College/Post-Secondary' => 'Faculty (Post-Graduate)',
          'General Educator' => 'General Educator',
          'Museum Curator' => 'Museum Curator or Collections Manager',
          'Museum Staff' => 'Museum Staff',
          'Librarian' => 'Librarian',
          'IT' => 'IT Professional',
          'Private Individual' => 'Private Individual',
          'Researcher' => 'Researcher',
          'Private Industry' => 'Private Industry Professional',
          'Artist' => 'Artist',
          'Government' => 'Government Employee'
        },
        :software => {
          "don't know/no preference" => 'I Do Not Know/I Have No Preference',
          'Volume Graphics-StudioMax/myVGL' => 'Volume Graphics StudioMax or myVGL',
          'Avizo' => 'Avizo',
          'Amira' => 'Amira',
          '3D Slicer' => '3D Slicer',
          'Geomagic' => 'Geomagic',
          'Osirix' => 'Osirix',
          'Mimics' => 'Mimics',
          'Meshlab' => 'Meshlab',
          'ImageJ' => 'ImageJ',
          'Fiji' => 'Fiji'
        },
        :mesh_file_type => {
          "don't know/no preference" => 'I Do Not Know/I Have No Preference',
          '.ply' => 'PLY',
          '.stl' => 'STL',
          '.obj' => 'OBJ',
          '.off' => 'OFF',
          '.vrml' => 'VRML',
          '.surf - Avizo/Amira proprietary' => 'SURF (Avizo/Amira Proprietary Format)',
          '.wrap - geomagic proprietary' => 'WRAP (Geomagic Proprietary Format)',
          '.vgl - VG StudioMax proprietary' => 'VGL (VG StudioMax Proprietary Format)',
          '.pdf 3D - Adobe proprietary' => '3D PDF (Proprietary Adobe Format)',
          '.HxSurface' => 'HXSurface (Avizo/Amira Proprietary Format)',
          '.smb' => 'SMB',
          '.msh' => 'MSH',
          '.mesh' => 'MESH',
          '.raw' => 'RAW',
          '.3ds' => '3DS'
        },
        :volume_file_type => {
          "don't know/no preference" => 'I Do Not Know/I Have No Preference',
          '16-bit tiff/jpeg image stack' => 'Multiple 16-bit TIFF Image Stack Files',
          '8-bit tiff/jpeg image stack' => 'Multiple 8-bit TIFF Image Stack Files',
          'Dicom image stack' => 'Multiple DICOM-format Image Stack Files',
          '3D tiff' => 'Single 16-bit Multiframe TIFF File',
          '3D dicom' => 'Single Multiframe DICOM File',
          '.vgl - VG StudioMax proprietary' => 'VGL (VG StudioMax Proprietary Format)',
          'DXF' => '',
          'VRML' => '',
          'Wavefron OBJ' => ''
        },
        :userclass => {
          '1' => true,
          '50' => false,
          '100' => false,
          '255' => false
        }
      }

      def mappings
        { # MS1 -> MS2
          '3D_printer' => :printer_model,
          '3D_printer_software' => :printer_software,
          :country => :country,
          :email => :email,
          :organization => :affiliation,
          :password => :ms1_password_hash,
          :phone => :telephone,
          :postalcode => :postal_code,
          :registered_on => :created_at,
          :state => :state,
          :terms_conditions => :terms_read,
          :user_id => :ms_id,
          :userclass => :contributor
        }
      end

      def control_vocab_mappings
        self.class_control_vocab_mappings
      end

      def expected_special_fields
        [:display_name, :address, :demographics, :software, :mesh_file_type, 
         :volume_file_type]
      end
    end
  end
end 