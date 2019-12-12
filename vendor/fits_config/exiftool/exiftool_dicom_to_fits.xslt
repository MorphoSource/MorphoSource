<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="exiftool_common_to_fits.xslt"/>

  <xsl:template match="/">

    <fits xmlns="http://hul.harvard.edu/ois/xml/ns/fits/fits_output">   

      <xsl:apply-imports/>

      <metadata>
        <dicom>
          <modality>
            <xsl:value-of select="exiftool/Modality"/>
          </modality>
          <spacingBetweenSlices>
            <xsl:value-of select="exiftool/SpacingBetweenSlices"/>
          </spacingBetweenSlices>
          <secondaryCaptureDeviceManufacturer>
            <xsl:value-of select="exiftool/SecondaryCaptureDeviceManufacturer"/>
          </secondaryCaptureDeviceManufacturer>
          <secondaryCaptureDeviceSoftwareVers>
            <xsl:value-of select="exiftool/SecondaryCaptureDeviceSoftwareVers"/>
          </secondaryCaptureDeviceSoftwareVers>
          <fileName>
            <xsl:value-of select="exiftool/FileName"/>
          </fileName>
          <fileSize>
            <xsl:value-of select="exiftool/FileSize"/>
          </fileSize>
          <fileType>
            <xsl:value-of select="exiftool/FileType"/>
          </fileType>
          <fileTypeExtension>
            <xsl:value-of select="exiftool/FileTypeExtension"/>
          </fileTypeExtension>
          <fileMetaInfoGroupLength>
            <xsl:value-of select="exiftool/FileMetaInfoGroupLength"/>
          </fileMetaInfoGroupLength>
          <fileMetaInfoVersion>
            <xsl:value-of select="exiftool/FileMetaInfoVersion"/>
          </fileMetaInfoVersion>
          <mediaStorageSOPClassUID>
            <xsl:value-of select="exiftool/MediaStorageSOPClassUID"/>
          </mediaStorageSOPClassUID>
          <mediaStorageSOPInstanceUID>
            <xsl:value-of select="exiftool/MediaStorageSOPInstanceUID"/>
          </mediaStorageSOPInstanceUID>
          <transferSyntaxUID>
            <xsl:value-of select="exiftool/TransferSyntaxUID"/>
          </transferSyntaxUID>
          <implementationClassUID>
            <xsl:value-of select="exiftool/ImplementationClassUID"/>
          </implementationClassUID>
          <implementationVersionName>
            <xsl:value-of select="exiftool/ImplementationVersionName"/>
          </implementationVersionName>
          <specificCharacterSet>
            <xsl:value-of select="exiftool/SpecificCharacterSet"/>
          </specificCharacterSet>
          <imageType>
            <xsl:value-of select="exiftool/ImageType"/>
          </imageType>
          <SOPClassUID>
            <xsl:value-of select="exiftool/SOPClassUID"/>
          </SOPClassUID>
          <SOPInstanceUID>
            <xsl:value-of select="exiftool/SOPInstanceUID"/>
          </SOPInstanceUID>
          <studyDate>
            <xsl:value-of select="exiftool/StudyDate"/>
          </studyDate>
          <seriesDate>
            <xsl:value-of select="exiftool/SeriesDate"/>
          </seriesDate>
          <contentDate>
            <xsl:value-of select="exiftool/ContentDate"/>
          </contentDate>
          <studyTime>
            <xsl:value-of select="exiftool/StudyTime"/>
          </studyTime>
          <seriesTime>
            <xsl:value-of select="exiftool/SeriesTime"/>
          </seriesTime>
          <contentTime>
            <xsl:value-of select="exiftool/ContentTime"/>
          </contentTime>
          <accessionNumber>
            <xsl:value-of select="exiftool/AccessionNumber"/>
          </accessionNumber>
          <conversionType>
            <xsl:value-of select="exiftool/ConversionType"/>
          </conversionType>
          <referringPhysicianName>
            <xsl:value-of select="exiftool/ReferringPhysicianName"/>
          </referringPhysicianName>
          <studyDescription>
            <xsl:value-of select="exiftool/StudyDescription"/>
          </studyDescription>
          <seriesDescription>
            <xsl:value-of select="exiftool/SeriesDescription"/>
          </seriesDescription>
          <patientName>
            <xsl:value-of select="exiftool/PatientName"/>
          </patientName>
          <patientID>
            <xsl:value-of select="exiftool/PatientID"/>
          </patientID>
          <patientBirthDate>
            <xsl:value-of select="exiftool/PatientBirthDate"/>
          </patientBirthDate>
          <studyInstanceUID>
            <xsl:value-of select="exiftool/StudyInstanceUID"/>
          </studyInstanceUID>
          <seriesInstanceUID>
            <xsl:value-of select="exiftool/SeriesInstanceUID"/>
          </seriesInstanceUID>
          <instanceNumber>
            <xsl:value-of select="exiftool/InstanceNumber"/>
          </instanceNumber>
          <imagePositionPatient>
            <xsl:value-of select="exiftool/ImagePositionPatient"/>
          </imagePositionPatient>
          <imageOrientationPatient>
            <xsl:value-of select="exiftool/ImageOrientationPatient"/>
          </imageOrientationPatient>
          <samplesPerPixel>
            <xsl:value-of select="exiftool/SamplesPerPixel"/>
          </samplesPerPixel>
          <photometricInterpretation>
            <xsl:value-of select="exiftool/PhotometricInterpretation"/>
          </photometricInterpretation>
          <rows>
            <xsl:value-of select="exiftool/Rows"/>
          </rows>
          <columns>
            <xsl:value-of select="exiftool/Columns"/>
          </columns>
          <pixelSpacing>
            <xsl:value-of select="exiftool/PixelSpacing"/>
          </pixelSpacing>
          <sliceThickness>
            <xsl:value-of select="exiftool/SliceThickness"/>
          </sliceThickness>
          <bitsAllocated>
            <xsl:value-of select="exiftool/BitsAllocated"/>
          </bitsAllocated>
          <bitsStored>
            <xsl:value-of select="exiftool/BitsStored"/>
          </bitsStored>
          <highBit>
            <xsl:value-of select="exiftool/HighBit"/>
          </highBit>
          <pixelRepresentation>
            <xsl:value-of select="exiftool/PixelRepresentation"/>
          </pixelRepresentation>
          <windowCenter>
            <xsl:value-of select="exiftool/WindowCenter"/>
          </windowCenter>
          <windowWidth>
            <xsl:value-of select="exiftool/WindowWidth"/>
          </windowWidth>
          <rescaleIntercept>
            <xsl:value-of select="exiftool/RescaleIntercept"/>
          </rescaleIntercept>
          <rescaleSlope>
            <xsl:value-of select="exiftool/RescaleSlope"/>
          </rescaleSlope>
          <windowCenterAndWidthExplanation>
            <xsl:value-of select="exiftool/WindowCenterAndWidthExplanation"/>
          </windowCenterAndWidthExplanation>
          <pixelData>
            <xsl:value-of select="exiftool/PixelData"/>
          </pixelData>
        </dicom>				
      </metadata>
    </fits>	

  </xsl:template>

</xsl:stylesheet>