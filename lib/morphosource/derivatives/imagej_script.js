#@ String input_path
#@ String output_path
#@ Float linear_scale_factor

importClass(Packages.ij.IJ);
importClass(Packages.ij.plugin.FolderOpener);
importClass(Packages.ij.plugin.StackWriter);

print('Opening image stack');
imp = FolderOpener.open(input_path, "virtual");
print('Checking bit depth and correcting if needed')
if (imp.getBitDepth() == 32) {
	IJ.run(imp, "16-bit", "");
} else if (imp.getBitDepth() == 24) {
	IJ.run(imp, "8-bit", "");
}
print('Resizing stack');
imp2 = imp.resize(
	parseInt(linear_scale_factor * imp.width), 
	parseInt(linear_scale_factor * imp.height), 
	parseInt(linear_scale_factor * imp.getNSlices()), 
	"bilinear"
);
print('Saving stack');
StackWriter.save(imp2, output_path, "format=tiff");
print('Finished!');