module Morphosource::UserProfile::CheckboxValues

  DEMOGRAPHICS =
    ["Student (Grades K-6)",
    "Student (Grades 7-12)",
    "Student (University or Post-Secondary)",
    "Student (Post-Graduate)",
    "Faculty (Grades K-6)",
    "Faculty (Grades K-7)",
    "Faculty (University or Post-Secondary)",
    "Faculty (Post-Graduate)",
    "University Staff",
    "General Educator",
    "Museum Curator or Collections Manager",
    "Museum Staff",
    "Librarian",
    "IT Professional",
    "Private Individual",
    "Researcher",
    "Private Industry Professional",
    "Artist",
    "Government Employee"]

  INTENT =
    ["Completing Class Assignment(s) (Grades K-6)",
    "Completing Class Assignment(s) (Grades 7-12)",
    "Completing Class Assignment(s) (University or Post-Secondary)",
    "Completing Class Assignment(s) (Post-Graduate)",
    "Educator Resource (Grades K-6)",
    "Educator Resource (Grades 7-12)",
    "Educator Resource (University or Post-Secondary)",
    "Educator Resource (Post-Graduate)",
    "Public Outreach (Museums, Documentaries, Etc)",
    "Research",
    "Art",
    "Personal Interest",
    "3D Printing"]

  SOFTWARE =
    ["I Do Not Know/I Have No Preference",
    "Meshlab",
    "3D Slicer",
    "ImageJ",
    "Fiji",
    "Avizo",
    "Amira",
    "Geomagic",
    "Volume Graphics StudioMax or myVGL",
    "Mimics",
    "Osirix",
    "Dragonfly",
    "Blender",
    "CloudCompare"]

  MESH =
    ["I Do Not Know/I Have No Preference",
    "STL",
    "OBJ",
    "PLY",
    "3D PDF (Proprietary Adobe Format)",
    "3DS",
    "SURF (Avizo/Amira Proprietary Format)",
    "RAW",
    "MESH",
    "VGL (VG StudioMax Proprietary Format)",
    "VRML",
    "WRAP (Geomagic Proprietary Format)",
    "MSH",
    "OFF",
    "HXSurface (Avizo/Amira Proprietary Format)",
    "SMB",
    "GLTF or GLB",
    "X3D"]

  VOLUME =
    ["I Do Not Know/I Have No Preference",
    "Multiple DICOM-format Image Stack Files",
    "Multiple 16-bit TIFF Image Stack Files",
    "Multiple 8-bit TIFF Image Stack Files",
    "Multiple JPEG Image Stack Files",
    "Single Multiframe DICOM File",
    "Single 16-bit Multiframe TIFF File",
    "Single 8-bit Multiframe TIFF File",
    "VGL (VG StudioMax Proprietary Format)",
    "NRRD",
    "NIfTI"]

  PRINTER_MODEL =
    ["I Do Not Know",
    "MakerBot Replicator",
    "XYZprinting da Vinci Mini",
    "Ultimaker 2",
    "Ultimaker 3",
    "FlashForge Creator",
    "LulzBot Mini",
    "LulzBot Taz",
    "CubePro Trio",
    "BeeVeryCreative BeeTheFirst"]

  PRINTER_FILE =
    ["I Do Not Know",
    "STL",
    "OBJ",
    "GCODE",
    "VRML",
    "3ML",
    "X3G",
    "AMF",
    "FBX",
    "PLY"]
end
