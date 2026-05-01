const libclang* {.strdefine.}= "libclang.so"
## 
## Error codes returned by libclang routines.
## 
## Zero (CXError_Success) is the only error code indicating success.  Other
## error codes, including not yet assigned non-zero values, indicate errors.
type enum_CXErrorCode* = cint
const
  CXError_Success* :enum_CXErrorCode= 0
  CXError_Failure* :enum_CXErrorCode= 1
  CXError_Crashed* :enum_CXErrorCode= 2
  CXError_InvalidArguments* :enum_CXErrorCode= 3
  CXError_ASTReadError* :enum_CXErrorCode= 4
type CXErrorCode* = enum_CXErrorCode
## 
## A character string.
## 
## The CXString type is used to return strings from the interface when
## the ownership of that string might differ from one call to the next.
## Use clang_getCString() to retrieve the string data and, once finished
## with the string data, call clang_disposeString() to free the string.
type
  ///
A ch* {.aracte.} = object
    data* :pointer
    private_flags* :cuint
  ype is used* {. to re.} = object
    r strin* :ptr g.

The 
    CXStr* :ing t
## 
## Retrieve the character data associated with the given string.
proc clang_getCString*(string :CXString) :cstring {.importc:"clang_getCString", cdecl, dynlib:libclang.}
## 
## Free the given string.
proc clang_disposeString*(string :CXString) {.importc:"clang_disposeString", cdecl, dynlib:libclang.}
## 
## Free the given string set.
proc clang_disposeStringSet*(set :ptr CXStringSet) {.importc:"clang_disposeStringSet", cdecl, dynlib:libclang.}
## 
## A particular source file that is part of a translation unit.
type CXFile* = pointer
## 
## Retrieve the complete file and path name of the given file.
proc clang_getFileName*(SFile :CXFile) :CXString {.importc:"clang_getFileName", cdecl, dynlib:libclang.}
## 
## Retrieve the last modification time of the given file.
proc clang_getFileTime*(SFile :CXFile) :clong {.importc:"clang_getFileTime", cdecl, dynlib:libclang.}
## 
## Uniquely identifies a CXFile, that refers to the same underlying file,
## across an indexing session.
type r source file * {.that i.} = object
  ///
* :array[a, A particul]
## 
## Retrieve the unique ID for the given file.
## 
## \param file the file to get the ID for.
## \param outID stores the returned CXFileUniqueID.
## \returns If there was a failure getting the unique ID, returns non-zero,
## otherwise returns 0.
proc clang_getFileUniqueID*(file :CXFile; outID :ptr CXFileUniqueID) :cint {.importc:"clang_getFileUniqueID", cdecl, dynlib:libclang.}
## 
## Returns non-zero if the file1 and file2 point to the same file,
## or they are both NULL.
proc clang_File_isEqual*(file1 :CXFile; file2 :CXFile) :cint {.importc:"clang_File_isEqual", cdecl, dynlib:libclang.}
## 
## Returns the real path name of file.
## 
## An empty string may be returned. Use clang_getFileName() in that case.
proc clang_File_tryGetRealPathName*(file :CXFile) :CXString {.importc:"clang_File_tryGetRealPathName", cdecl, dynlib:libclang.}
## 
## Identifies a specific source location within a translation
## unit.
## 
## Use clang_getExpansionLocation() or clang_getSpellingLocation()
## to map a source location to a particular file, line, and column.
type ///
Identifies a* {. speci.} = object
  ptr_data* :array[2, pointer]
  int_data* :cuint
## 
## Identifies a half-open character range in the source code.
## 
## Use clang_getRangeStart() and clang_getRangeEnd() to retrieve the
## starting and end locations from a source range, respectively.
type clang_getExpa* {.nsionL.} = object
  fic sour* :array[t, ce loca]
  ion within a t* :ransl
  ation
unit.
* :
Use 
## 
## Retrieve a NULL (invalid) source location.
proc clang_getNullLocation*() :CXSourceLocation {.importc:"clang_getNullLocation", cdecl, dynlib:libclang.}
## 
## Determine whether two source locations, which must refer into
## the same translation unit, refer to exactly the same point in the source
## code.
## 
## \returns non-zero if the source locations refer to the same location, zero
## if they refer to different locations.
proc clang_equalLocations*(loc1 :CXSourceLocation; loc2 :CXSourceLocation) :cuint {.importc:"clang_equalLocations", cdecl, dynlib:libclang.}
## 
## Returns non-zero if the given source location is in a system header.
proc clang_Location_isInSystemHeader*(location :CXSourceLocation) :cint {.importc:"clang_Location_isInSystemHeader", cdecl, dynlib:libclang.}
## 
## Returns non-zero if the given source location is in the main file of
## the corresponding translation unit.
proc clang_Location_isFromMainFile*(location :CXSourceLocation) :cint {.importc:"clang_Location_isFromMainFile", cdecl, dynlib:libclang.}
## 
## Retrieve a NULL (invalid) source range.
proc clang_getNullRange*() :CXSourceRange {.importc:"clang_getNullRange", cdecl, dynlib:libclang.}
## 
## Retrieve a source range given the beginning and ending source
## locations.
proc clang_getRange*(begin :CXSourceLocation; `end` :CXSourceLocation) :CXSourceRange {.importc:"clang_getRange", cdecl, dynlib:libclang.}
## 
## Determine whether two ranges are equivalent.
## 
## \returns non-zero if the ranges are the same, zero if they differ.
proc clang_equalRanges*(range1 :CXSourceRange; range2 :CXSourceRange) :cuint {.importc:"clang_equalRanges", cdecl, dynlib:libclang.}
## 
## Returns non-zero if range is null.
proc clang_Range_isNull*(range :CXSourceRange) :cint {.importc:"clang_Range_isNull", cdecl, dynlib:libclang.}
## 
## Retrieve the file, line, column, and offset represented by
## the given source location.
## 
## If the location refers into a macro expansion, retrieves the
## location of the macro expansion.
## 
## \param location the location within a source file that will be decomposed
## into its parts.
## 
## \param file [out] if non-NULL, will be set to the file to which the given
## source location points.
## 
## \param line [out] if non-NULL, will be set to the line to which the given
## source location points.
## 
## \param column [out] if non-NULL, will be set to the column to which the given
## source location points.
## 
## \param offset [out] if non-NULL, will be set to the offset into the
## buffer to which the given source location points.
proc clang_getExpansionLocation*(location :CXSourceLocation; file :ptr CXFile; line :ptr cuint; column :ptr cuint; offset :ptr cuint) {.importc:"clang_getExpansionLocation", cdecl, dynlib:libclang.}
## 
## Retrieve the file, line and column represented by the given source
## location, as specified in a # line directive.
## 
## Example: given the following source code in a file somefile.c
## 
## \code
## #123 "dummy.c" 1
## 
## static int func(void)
## {
##     return 0;
## }
## \endcode
## 
## the location information returned by this function would be
## 
## File: dummy.c Line: 124 Column: 12
## 
## whereas clang_getExpansionLocation would have returned
## 
## File: somefile.c Line: 3 Column: 12
## 
## \param location the location within a source file that will be decomposed
## into its parts.
## 
## \param filename [out] if non-NULL, will be set to the filename of the
## source location. Note that filenames returned will be for "virtual" files,
## which don't necessarily exist on the machine running clang - e.g. when
## parsing preprocessed output obtained from a different environment. If
## a non-NULL value is passed in, remember to dispose of the returned value
## using clang_disposeString() once you've finished with it. For an invalid
## source location, an empty string is returned.
## 
## \param line [out] if non-NULL, will be set to the line number of the
## source location. For an invalid source location, zero is returned.
## 
## \param column [out] if non-NULL, will be set to the column number of the
## source location. For an invalid source location, zero is returned.
proc clang_getPresumedLocation*(location :CXSourceLocation; filename :ptr CXString; line :ptr cuint; column :ptr cuint) {.importc:"clang_getPresumedLocation", cdecl, dynlib:libclang.}
## 
## Legacy API to retrieve the file, line, column, and offset represented
## by the given source location.
## 
## This interface has been replaced by the newer interface
## #clang_getExpansionLocation(). See that interface's documentation for
## details.
proc clang_getInstantiationLocation*(location :CXSourceLocation; file :ptr CXFile; line :ptr cuint; column :ptr cuint; offset :ptr cuint) {.importc:"clang_getInstantiationLocation", cdecl, dynlib:libclang.}
## 
## Retrieve the file, line, column, and offset represented by
## the given source location.
## 
## If the location refers into a macro instantiation, return where the
## location was originally spelled in the source file.
## 
## \param location the location within a source file that will be decomposed
## into its parts.
## 
## \param file [out] if non-NULL, will be set to the file to which the given
## source location points.
## 
## \param line [out] if non-NULL, will be set to the line to which the given
## source location points.
## 
## \param column [out] if non-NULL, will be set to the column to which the given
## source location points.
## 
## \param offset [out] if non-NULL, will be set to the offset into the
## buffer to which the given source location points.
proc clang_getSpellingLocation*(location :CXSourceLocation; file :ptr CXFile; line :ptr cuint; column :ptr cuint; offset :ptr cuint) {.importc:"clang_getSpellingLocation", cdecl, dynlib:libclang.}
## 
## Retrieve the file, line, column, and offset represented by
## the given source location.
## 
## If the location refers into a macro expansion, return where the macro was
## expanded or where the macro argument was written, if the location points at
## a macro argument.
## 
## \param location the location within a source file that will be decomposed
## into its parts.
## 
## \param file [out] if non-NULL, will be set to the file to which the given
## source location points.
## 
## \param line [out] if non-NULL, will be set to the line to which the given
## source location points.
## 
## \param column [out] if non-NULL, will be set to the column to which the given
## source location points.
## 
## \param offset [out] if non-NULL, will be set to the offset into the
## buffer to which the given source location points.
proc clang_getFileLocation*(location :CXSourceLocation; file :ptr CXFile; line :ptr cuint; column :ptr cuint; offset :ptr cuint) {.importc:"clang_getFileLocation", cdecl, dynlib:libclang.}
## 
## Retrieve a source location representing the first character within a
## source range.
proc clang_getRangeStart*(range :CXSourceRange) :CXSourceLocation {.importc:"clang_getRangeStart", cdecl, dynlib:libclang.}
## 
## Retrieve a source location representing the last character within a
## source range.
proc clang_getRangeEnd*(range :CXSourceRange) :CXSourceLocation {.importc:"clang_getRangeEnd", cdecl, dynlib:libclang.}
## 
## Identifies an array of ranges.
type gLocation()
to ma* {.p a so.} = object
  ocati* :on() 
  or cla* :ptr ng_getSpellin
## 
## Destroy the given CXSourceRangeList.
proc clang_disposeSourceRangeList*(ranges :ptr CXSourceRangeList) {.importc:"clang_disposeSourceRangeList", cdecl, dynlib:libclang.}
## 
## Describes the severity of a particular diagnostic.
type enum_CXDiagnosticSeverity* = cint
const
  CXDiagnostic_Ignored* :enum_CXDiagnosticSeverity= 0
  CXDiagnostic_Note* :enum_CXDiagnosticSeverity= 1
  CXDiagnostic_Warning* :enum_CXDiagnosticSeverity= 2
  CXDiagnostic_Error* :enum_CXDiagnosticSeverity= 3
  CXDiagnostic_Fatal* :enum_CXDiagnosticSeverity= 4
type CXDiagnosticSeverity* = enum_CXDiagnosticSeverity
## 
## A single diagnostic, containing the diagnostic's severity,
## location, text, source ranges, and fix-it hints.
type CXDiagnostic* = pointer
## 
## A group of CXDiagnostics.
type CXDiagnosticSet* = pointer
## 
## Determine the number of diagnostics in a CXDiagnosticSet.
proc clang_getNumDiagnosticsInSet*(Diags :CXDiagnosticSet) :cuint {.importc:"clang_getNumDiagnosticsInSet", cdecl, dynlib:libclang.}
## 
## Retrieve a diagnostic associated with the given CXDiagnosticSet.
## 
## \param Diags the CXDiagnosticSet to query.
## \param Index the zero-based diagnostic number to retrieve.
## 
## \returns the requested diagnostic. This diagnostic must be freed
## via a call to clang_disposeDiagnostic().
proc clang_getDiagnosticInSet*(Diags :CXDiagnosticSet; Index :cuint) :CXDiagnostic {.importc:"clang_getDiagnosticInSet", cdecl, dynlib:libclang.}
## 
## Describes the kind of error that occurred (if any) in a call to
## clang_loadDiagnostics.
type enum_CXLoadDiag_Error* = cint
const
  CXLoadDiag_None* :enum_CXLoadDiag_Error= 0
  CXLoadDiag_Unknown* :enum_CXLoadDiag_Error= 1
  CXLoadDiag_CannotLoad* :enum_CXLoadDiag_Error= 2
  CXLoadDiag_InvalidFile* :enum_CXLoadDiag_Error= 3
type CXLoadDiag_Error* = enum_CXLoadDiag_Error
## 
## Deserialize a set of diagnostics from a Clang diagnostics bitcode
## file.
## 
## \param file The name of the file to deserialize.
## \param error A pointer to a enum value recording if there was a problem
##        deserializing the diagnostics.
## \param errorString A pointer to a CXString for recording the error string
##        if the file was not successfully loaded.
## 
## \returns A loaded CXDiagnosticSet if successful, and NULL otherwise.  These
## diagnostics should be released using clang_disposeDiagnosticSet().
proc clang_loadDiagnostics*(file :cstring; error :ptr CXLoadDiag_Error; errorString :ptr CXString) :CXDiagnosticSet {.importc:"clang_loadDiagnostics", cdecl, dynlib:libclang.}
## 
## Release a CXDiagnosticSet and all of its contained diagnostics.
proc clang_disposeDiagnosticSet*(Diags :CXDiagnosticSet) {.importc:"clang_disposeDiagnosticSet", cdecl, dynlib:libclang.}
## 
## Retrieve the child diagnostics of a CXDiagnostic.
## 
## This CXDiagnosticSet does not need to be released by
## clang_disposeDiagnosticSet.
proc clang_getChildDiagnostics*(D :CXDiagnostic) :CXDiagnosticSet {.importc:"clang_getChildDiagnostics", cdecl, dynlib:libclang.}
## 
## Destroy a diagnostic.
proc clang_disposeDiagnostic*(Diagnostic :CXDiagnostic) {.importc:"clang_disposeDiagnostic", cdecl, dynlib:libclang.}
## 
## Options to control the display of diagnostics.
## 
## The values in this enum are meant to be combined to customize the
## behavior of clang_formatDiagnostic().
type enum_CXDiagnosticDisplayOptions* = cint
const
  CXDiagnostic_DisplaySourceLocation* :enum_CXDiagnosticDisplayOptions= 1
  CXDiagnostic_DisplayColumn* :enum_CXDiagnosticDisplayOptions= 2
  CXDiagnostic_DisplaySourceRanges* :enum_CXDiagnosticDisplayOptions= 4
  CXDiagnostic_DisplayOption* :enum_CXDiagnosticDisplayOptions= 8
  CXDiagnostic_DisplayCategoryId* :enum_CXDiagnosticDisplayOptions= 16
  CXDiagnostic_DisplayCategoryName* :enum_CXDiagnosticDisplayOptions= 32
type CXDiagnosticDisplayOptions* = enum_CXDiagnosticDisplayOptions
## 
## Format the given diagnostic in a manner that is suitable for display.
## 
## This routine will format the given diagnostic to a string, rendering
## the diagnostic according to the various options given. The
## clang_defaultDiagnosticDisplayOptions() function returns the set of
## options that most closely mimics the behavior of the clang compiler.
## 
## \param Diagnostic The diagnostic to print.
## 
## \param Options A set of options that control the diagnostic display,
## created by combining CXDiagnosticDisplayOptions values.
## 
## \returns A new string containing for formatted diagnostic.
proc clang_formatDiagnostic*(Diagnostic :CXDiagnostic; Options :cuint) :CXString {.importc:"clang_formatDiagnostic", cdecl, dynlib:libclang.}
## 
## Retrieve the set of display options most similar to the
## default behavior of the clang compiler.
## 
## \returns A set of display options suitable for use with \c
## clang_formatDiagnostic().
proc clang_defaultDiagnosticDisplayOptions*() :cuint {.importc:"clang_defaultDiagnosticDisplayOptions", cdecl, dynlib:libclang.}
## 
## Determine the severity of the given diagnostic.
proc clang_getDiagnosticSeverity*(a0 :CXDiagnostic) :CXDiagnosticSeverity {.importc:"clang_getDiagnosticSeverity", cdecl, dynlib:libclang.}
## 
## Retrieve the source location of the given diagnostic.
## 
## This location is where Clang would print the caret ('^') when
## displaying the diagnostic on the command line.
proc clang_getDiagnosticLocation*(a0 :CXDiagnostic) :CXSourceLocation {.importc:"clang_getDiagnosticLocation", cdecl, dynlib:libclang.}
## 
## Retrieve the text of the given diagnostic.
proc clang_getDiagnosticSpelling*(a0 :CXDiagnostic) :CXString {.importc:"clang_getDiagnosticSpelling", cdecl, dynlib:libclang.}
## 
## Retrieve the name of the command-line option that enabled this
## diagnostic.
## 
## \param Diag The diagnostic to be queried.
## 
## \param Disable If non-NULL, will be set to the option that disables this
## diagnostic (if any).
## 
## \returns A string that contains the command-line option used to enable this
## warning, such as "-Wconversion" or "-pedantic".
proc clang_getDiagnosticOption*(Diag :CXDiagnostic; Disable :ptr CXString) :CXString {.importc:"clang_getDiagnosticOption", cdecl, dynlib:libclang.}
## 
## Retrieve the category number for this diagnostic.
## 
## Diagnostics can be categorized into groups along with other, related
## diagnostics (e.g., diagnostics under the same warning flag). This routine
## retrieves the category number for the given diagnostic.
## 
## \returns The number of the category that contains this diagnostic, or zero
## if this diagnostic is uncategorized.
proc clang_getDiagnosticCategory*(a0 :CXDiagnostic) :cuint {.importc:"clang_getDiagnosticCategory", cdecl, dynlib:libclang.}
## 
## Retrieve the name of a particular diagnostic category.  This
##  is now deprecated.  Use clang_getDiagnosticCategoryText()
##  instead.
## 
## \param Category A diagnostic category number, as returned by
## clang_getDiagnosticCategory().
## 
## \returns The name of the given diagnostic category.
proc clang_getDiagnosticCategoryName*(Category :cuint) :CXString {.importc:"clang_getDiagnosticCategoryName", cdecl, dynlib:libclang.}
## 
## Retrieve the diagnostic category text for a given diagnostic.
## 
## \returns The text of the given diagnostic category.
proc clang_getDiagnosticCategoryText*(a0 :CXDiagnostic) :CXString {.importc:"clang_getDiagnosticCategoryText", cdecl, dynlib:libclang.}
## 
## Determine the number of source ranges associated with the given
## diagnostic.
proc clang_getDiagnosticNumRanges*(a0 :CXDiagnostic) :cuint {.importc:"clang_getDiagnosticNumRanges", cdecl, dynlib:libclang.}
## 
## Retrieve a source range associated with the diagnostic.
## 
## A diagnostic's source ranges highlight important elements in the source
## code. On the command line, Clang displays source ranges by
## underlining them with '~' characters.
## 
## \param Diagnostic the diagnostic whose range is being extracted.
## 
## \param Range the zero-based index specifying which range to
## 
## \returns the requested source range.
proc clang_getDiagnosticRange*(Diagnostic :CXDiagnostic; Range :cuint) :CXSourceRange {.importc:"clang_getDiagnosticRange", cdecl, dynlib:libclang.}
## 
## Determine the number of fix-it hints associated with the
## given diagnostic.
proc clang_getDiagnosticNumFixIts*(Diagnostic :CXDiagnostic) :cuint {.importc:"clang_getDiagnosticNumFixIts", cdecl, dynlib:libclang.}
## 
## Retrieve the replacement information for a given fix-it.
## 
## Fix-its are described in terms of a source range whose contents
## should be replaced by a string. This approach generalizes over
## three kinds of operations: removal of source code (the range covers
## the code to be removed and the replacement string is empty),
## replacement of source code (the range covers the code to be
## replaced and the replacement string provides the new code), and
## insertion (both the start and end of the range point at the
## insertion location, and the replacement string provides the text to
## insert).
## 
## \param Diagnostic The diagnostic whose fix-its are being queried.
## 
## \param FixIt The zero-based index of the fix-it.
## 
## \param ReplacementRange The source range whose contents will be
## replaced with the returned replacement string. Note that source
## ranges are half-open ranges [a, b), so the source code should be
## replaced from a and up to (but not including) b.
## 
## \returns A string containing text that should be replace the source
## code indicated by the ReplacementRange.
proc clang_getDiagnosticFixIt*(Diagnostic :CXDiagnostic; FixIt :cuint; ReplacementRange :ptr CXSourceRange) :CXString {.importc:"clang_getDiagnosticFixIt", cdecl, dynlib:libclang.}
const CINDEX_VERSION_MAJOR* = 0
const CINDEX_VERSION_MINOR* = 64
## 
## Return the timestamp for use with Clang's
## -fbuild-session-timestamp= option.
proc clang_getBuildSessionTimestamp*() :culonglong {.importc:"clang_getBuildSessionTimestamp", cdecl, dynlib:libclang.}
type
  struct_CXVirtualFileOverlayImpl* {.incompleteStruct.} = object
  CXVirtualFileOverlayImpl* = struct_CXVirtualFileOverlayImpl
## 
## Object encapsulating information about overlaying virtual
## file/directories over the real file system.
type CXVirtualFileOverlay* = ptr struct_CXVirtualFileOverlayImpl
## 
## Create a CXVirtualFileOverlay object.
## Must be disposed with clang_VirtualFileOverlay_dispose().
## 
## \param options is reserved, always pass 0.
proc clang_VirtualFileOverlay_create*(options :cuint) :CXVirtualFileOverlay {.importc:"clang_VirtualFileOverlay_create", cdecl, dynlib:libclang.}
## 
## Map an absolute virtual file path to an absolute real one.
## The virtual path must be canonicalized (not contain "."/"..").
## \returns 0 for success, non-zero to indicate an error.
proc clang_VirtualFileOverlay_addFileMapping*(a0 :CXVirtualFileOverlay; virtualPath :cstring; realPath :cstring) :CXErrorCode {.importc:"clang_VirtualFileOverlay_addFileMapping", cdecl, dynlib:libclang.}
## 
## Set the case sensitivity for the CXVirtualFileOverlay object.
## The CXVirtualFileOverlay object is case-sensitive by default, this
## option can be used to override the default.
## \returns 0 for success, non-zero to indicate an error.
proc clang_VirtualFileOverlay_setCaseSensitivity*(a0 :CXVirtualFileOverlay; caseSensitive :cint) :CXErrorCode {.importc:"clang_VirtualFileOverlay_setCaseSensitivity", cdecl, dynlib:libclang.}
## 
## Write out the CXVirtualFileOverlay object to a char buffer.
## 
## \param options is reserved, always pass 0.
## \param out_buffer_ptr pointer to receive the buffer pointer, which should be
## disposed using clang_free().
## \param out_buffer_size pointer to receive the buffer size.
## \returns 0 for success, non-zero to indicate an error.
proc clang_VirtualFileOverlay_writeToBuffer*(a0 :CXVirtualFileOverlay; options :cuint; out_buffer_ptr :ptr cstring; out_buffer_size :ptr cuint) :CXErrorCode {.importc:"clang_VirtualFileOverlay_writeToBuffer", cdecl, dynlib:libclang.}
## 
## free memory allocated by libclang, such as the buffer returned by
## CXVirtualFileOverlay() or clang_ModuleMapDescriptor_writeToBuffer().
## 
## \param buffer memory pointer to free.
proc clang_free*(buffer :pointer) {.importc:"clang_free", cdecl, dynlib:libclang.}
## 
## Dispose a CXVirtualFileOverlay object.
proc clang_VirtualFileOverlay_dispose*(a0 :CXVirtualFileOverlay) {.importc:"clang_VirtualFileOverlay_dispose", cdecl, dynlib:libclang.}
type
  struct_CXModuleMapDescriptorImpl* {.incompleteStruct.} = object
  CXModuleMapDescriptorImpl* = struct_CXModuleMapDescriptorImpl
## 
## Object encapsulating information about a module.modulemap file.
type CXModuleMapDescriptor* = ptr struct_CXModuleMapDescriptorImpl
## 
## Create a CXModuleMapDescriptor object.
## Must be disposed with clang_ModuleMapDescriptor_dispose().
## 
## \param options is reserved, always pass 0.
proc clang_ModuleMapDescriptor_create*(options :cuint) :CXModuleMapDescriptor {.importc:"clang_ModuleMapDescriptor_create", cdecl, dynlib:libclang.}
## 
## Sets the framework module name that the module.modulemap describes.
## \returns 0 for success, non-zero to indicate an error.
proc clang_ModuleMapDescriptor_setFrameworkModuleName*(a0 :CXModuleMapDescriptor; name :cstring) :CXErrorCode {.importc:"clang_ModuleMapDescriptor_setFrameworkModuleName", cdecl, dynlib:libclang.}
## 
## Sets the umbrella header name that the module.modulemap describes.
## \returns 0 for success, non-zero to indicate an error.
proc clang_ModuleMapDescriptor_setUmbrellaHeader*(a0 :CXModuleMapDescriptor; name :cstring) :CXErrorCode {.importc:"clang_ModuleMapDescriptor_setUmbrellaHeader", cdecl, dynlib:libclang.}
## 
## Write out the CXModuleMapDescriptor object to a char buffer.
## 
## \param options is reserved, always pass 0.
## \param out_buffer_ptr pointer to receive the buffer pointer, which should be
## disposed using clang_free().
## \param out_buffer_size pointer to receive the buffer size.
## \returns 0 for success, non-zero to indicate an error.
proc clang_ModuleMapDescriptor_writeToBuffer*(a0 :CXModuleMapDescriptor; options :cuint; out_buffer_ptr :ptr cstring; out_buffer_size :ptr cuint) :CXErrorCode {.importc:"clang_ModuleMapDescriptor_writeToBuffer", cdecl, dynlib:libclang.}
## 
## Dispose a CXModuleMapDescriptor object.
proc clang_ModuleMapDescriptor_dispose*(a0 :CXModuleMapDescriptor) {.importc:"clang_ModuleMapDescriptor_dispose", cdecl, dynlib:libclang.}
## 
## An "index" that consists of a set of translation units that would
## typically be linked together into an executable or library.
type
  CXIndex* = pointer
  struct_CXTargetInfoImpl* {.incompleteStruct.} = object
  CXTargetInfoImpl* = struct_CXTargetInfoImpl
## 
## An opaque type representing target information for a given translation
## unit.
type
  CXTargetInfo* = ptr struct_CXTargetInfoImpl
  struct_CXTranslationUnitImpl* {.incompleteStruct.} = object
  CXTranslationUnitImpl* = struct_CXTranslationUnitImpl
## 
## A single translation unit, which resides in an index.
type CXTranslationUnit* = ptr struct_CXTranslationUnitImpl
## 
## Opaque pointer representing client data that will be passed through
## to various callbacks and visitors.
type CXClientData* = pointer
## 
## Provides the contents of a file that has not yet been saved to disk.
## 
## Each CXUnsavedFile instance provides the name of a file on the
## system along with the current contents of that file that have not
## yet been saved to disk.
type
  lincompleteStructCXV* {.irtual.} = object
    amp= opt* :ion.str
    uct_CXVi* :rtualFi
    leOver* :layImp
  CXUnsavedFile* = struct_CXUnsavedFile
## 
## Describes the availability of a particular entity, which indicates
## whether the use of this entity will result in a warning or error due to
## it being deprecated or unavailable.
type enum_CXAvailabilityKind* = cint
const
  CXAvailability_Available* :enum_CXAvailabilityKind= 0
  CXAvailability_Deprecated* :enum_CXAvailabilityKind= 1
  CXAvailability_NotAvailable* :enum_CXAvailabilityKind= 2
  CXAvailability_NotAccessible* :enum_CXAvailabilityKind= 3
type CXAvailabilityKind* = enum_CXAvailabilityKind
## 
## Describes a version number of the form major.minor.subminor.
type
  lFileOverlayImpl* {.///
Ob.} = object
    FileO* :verl
    ayImp* :lstr
    uct_CXVi* :rtua
  CXVersion* = struct_CXVersion
## 
## Describes the exception specification of a cursor.
## 
## A negative value indicates that the cursor is not a function declaration.
type enum_CXCursor_ExceptionSpecificationKind* = cint
const
  CXCursor_ExceptionSpecificationKind_None* :enum_CXCursor_ExceptionSpecificationKind= 0
  CXCursor_ExceptionSpecificationKind_DynamicNone* :enum_CXCursor_ExceptionSpecificationKind= 1
  CXCursor_ExceptionSpecificationKind_Dynamic* :enum_CXCursor_ExceptionSpecificationKind= 2
  CXCursor_ExceptionSpecificationKind_MSAny* :enum_CXCursor_ExceptionSpecificationKind= 3
  CXCursor_ExceptionSpecificationKind_BasicNoexcept* :enum_CXCursor_ExceptionSpecificationKind= 4
  CXCursor_ExceptionSpecificationKind_ComputedNoexcept* :enum_CXCursor_ExceptionSpecificationKind= 5
  CXCursor_ExceptionSpecificationKind_Unevaluated* :enum_CXCursor_ExceptionSpecificationKind= 6
  CXCursor_ExceptionSpecificationKind_Uninstantiated* :enum_CXCursor_ExceptionSpecificationKind= 7
  CXCursor_ExceptionSpecificationKind_Unparsed* :enum_CXCursor_ExceptionSpecificationKind= 8
  CXCursor_ExceptionSpecificationKind_NoThrow* :enum_CXCursor_ExceptionSpecificationKind= 9
type CXCursor_ExceptionSpecificationKind* = enum_CXCursor_ExceptionSpecificationKind
## 
## Provides a shared context for creating translation units.
## 
## It provides two options:
## 
## - excludeDeclarationsFromPCH: When non-zero, allows enumeration of "local"
## declarations (when loading any new translation units). A "local" declaration
## is one that belongs in the translation unit itself and not in a precompiled
## header that was used by the translation unit. If zero, all declarations
## will be enumerated.
## 
## Here is an example:
## 
## \code
##   // excludeDeclsFromPCH = 1, displayDiagnostics=1
##   Idx = clang_createIndex(1, 1);
## 
##   // IndexTest.pch was produced with the following command:
##   // "clang -x c IndexTest.h -emit-ast -o IndexTest.pch"
##   TU = clang_createTranslationUnit(Idx, "IndexTest.pch");
## 
##   // This will load all the symbols from 'IndexTest.pch'
##   clang_visitChildren(clang_getTranslationUnitCursor(TU),
##                       TranslationUnitVisitor, 0);
##   clang_disposeTranslationUnit(TU);
## 
##   // This will load all the symbols from 'IndexTest.c', excluding symbols
##   // from 'IndexTest.pch'.
##   char *args[] = { "-Xclang", "-include-pch=IndexTest.pch" };
##   TU = clang_createTranslationUnitFromSourceFile(Idx, "IndexTest.c", 2, args,
##                                                  0, 0);
##   clang_visitChildren(clang_getTranslationUnitCursor(TU),
##                       TranslationUnitVisitor, 0);
##   clang_disposeTranslationUnit(TU);
## \endcode
## 
## This process of creating the 'pch', loading it separately, and using it (via
## -include-pch) allows 'excludeDeclsFromPCH' to remove redundant callbacks
## (which gives the indexer the same performance benefit as the compiler).
proc clang_createIndex*(excludeDeclarationsFromPCH :cint; displayDiagnostics :cint) :CXIndex {.importc:"clang_createIndex", cdecl, dynlib:libclang.}
## 
## Destroy the given index.
## 
## The index must not be destroyed until all of the translation units created
## within that index have been destroyed.
proc clang_disposeIndex*(index :CXIndex) {.importc:"clang_disposeIndex", cdecl, dynlib:libclang.}
type enum_CXChoice* = cint
const
  CXChoice_Default* :enum_CXChoice= 0
  CXChoice_Enabled* :enum_CXChoice= 1
  CXChoice_Disabled* :enum_CXChoice= 2
type
  CXChoice* = enum_CXChoice
  enum_CXGlobalOptFlags* = cint
const
  CXGlobalOpt_None* :enum_CXGlobalOptFlags= 0
  CXGlobalOpt_ThreadBackgroundPriorityForIndexing* :enum_CXGlobalOptFlags= 1
  CXGlobalOpt_ThreadBackgroundPriorityForEditing* :enum_CXGlobalOptFlags= 2
  CXGlobalOpt_ThreadBackgroundPriorityForAll* :enum_CXGlobalOptFlags= 3
type CXGlobalOptFlags* = enum_CXGlobalOptFlags
## 
## Index initialization options.
## 
## 0 is the default value of each member of this struct except for Size.
## Initialize the struct in one of the following three ways to avoid adapting
## code each time a new member is added to it:
## \code
## CXIndexOptions Opts;
## memset(&Opts, 0, sizeof(Opts));
## Opts.Size = sizeof(CXIndexOptions);
## \endcode
## or explicitly initialize the first data member and zero-initialize the rest:
## \code
## CXIndexOptions Opts = { sizeof(CXIndexOptions) };
## \endcode
## or to prevent the -Wmissing-field-initializers warning for the above version:
## \code
## CXIndexOptions Opts{};
## Opts.Size = sizeof(CXIndexOptions);
## \endcode
type
  tc"clang_VirtualFileO* {.verlay.} = object
    ject* : enca
    psulating information about overlay* :ing v
    irtual
file/directories over the r* :eal f
    ile system.struct_CXVirtua* :lFile
    OverlayImplCXVirtu* :alFil
    eOverlayclang_VirtualF* :ileOv
    erlay_cr* :eateC
    XVirtualFileOverlay* :options
    cuintdynliblibclangcde* :climpor
  CXIndexOptions* = struct_CXIndexOptions
## 
## Provides a shared context for creating translation units.
## 
## Call this function instead of clang_createIndex() if you need to configure
## the additional options in CXIndexOptions.
## 
## \returns The created index or null in case of error, such as an unsupported
## value of options->Size.
## 
## For example:
## \code
## CXIndex createIndex(const char *ApplicationTemporaryPath) {
##   const int ExcludeDeclarationsFromPCH = 1;
##   const int DisplayDiagnostics = 1;
##   CXIndex Idx;
## #if CINDEX_VERSION_MINOR >= 64
##   CXIndexOptions Opts;
##   memset(&Opts, 0, sizeof(Opts));
##   Opts.Size = sizeof(CXIndexOptions);
##   Opts.ThreadBackgroundPriorityForIndexing = 1;
##   Opts.ExcludeDeclarationsFromPCH = ExcludeDeclarationsFromPCH;
##   Opts.DisplayDiagnostics = DisplayDiagnostics;
##   Opts.PreambleStoragePath = ApplicationTemporaryPath;
##   Idx = clang_createIndexWithOptions(&Opts);
##   if (Idx)
##     return Idx;
##   fprintf(stderr,
##           "clang_createIndexWithOptions() failed. "
##           "CINDEX_VERSION_MINOR = %d, sizeof(CXIndexOptions) = %u\n",
##           CINDEX_VERSION_MINOR, Opts.Size);
## #else
##   (void)ApplicationTemporaryPath;
## #endif
##   Idx = clang_createIndex(ExcludeDeclarationsFromPCH, DisplayDiagnostics);
##   clang_CXIndex_setGlobalOptions(
##       Idx, clang_CXIndex_getGlobalOptions(Idx) |
##                CXGlobalOpt_ThreadBackgroundPriorityForIndexing);
##   return Idx;
## }
## \endcode
## 
## \sa clang_createIndex()
proc clang_createIndexWithOptions*(options :ptr CXIndexOptions) :CXIndex {.importc:"clang_createIndexWithOptions", cdecl, dynlib:libclang.}
## 
## Sets general options associated with a CXIndex.
## 
## This function is DEPRECATED. Set
## CXIndexOptions::ThreadBackgroundPriorityForIndexing and/or
## CXIndexOptions::ThreadBackgroundPriorityForEditing and call
## clang_createIndexWithOptions() instead.
## 
## For example:
## \code
## CXIndex idx = ...;
## clang_CXIndex_setGlobalOptions(idx,
##     clang_CXIndex_getGlobalOptions(idx) |
##     CXGlobalOpt_ThreadBackgroundPriorityForIndexing);
## \endcode
## 
## \param options A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags.
proc clang_CXIndex_setGlobalOptions*(a0 :CXIndex; options :cuint) {.importc:"clang_CXIndex_setGlobalOptions", cdecl, dynlib:libclang.}
## 
## Gets the general options associated with a CXIndex.
## 
## This function allows to obtain the final option values used by libclang after
## specifying the option policies via CXChoice enumerators.
## 
## \returns A bitmask of options, a bitwise OR of CXGlobalOpt_XXX flags that
## are associated with the given CXIndex object.
proc clang_CXIndex_getGlobalOptions*(a0 :CXIndex) :cuint {.importc:"clang_CXIndex_getGlobalOptions", cdecl, dynlib:libclang.}
## 
## Sets the invocation emission path option in a CXIndex.
## 
## This function is DEPRECATED. Set CXIndexOptions::InvocationEmissionPath and
## call clang_createIndexWithOptions() instead.
## 
## The invocation emission path specifies a path which will contain log
## files for certain libclang invocations. A null value (default) implies that
## libclang invocations are not logged..
proc clang_CXIndex_setInvocationEmissionPathOption*(a0 :CXIndex; Path :cstring) {.importc:"clang_CXIndex_setInvocationEmissionPathOption", cdecl, dynlib:libclang.}
## 
## Determine whether the given header is guarded against
## multiple inclusions, either with the conventional
## \#ifndef/\#define/\#endif macro guards or with \#pragma once.
proc clang_isFileMultipleIncludeGuarded*(tu :CXTranslationUnit; file :CXFile) :cuint {.importc:"clang_isFileMultipleIncludeGuarded", cdecl, dynlib:libclang.}
## 
## Retrieve a file handle within the given translation unit.
## 
## \param tu the translation unit
## 
## \param file_name the name of the file.
## 
## \returns the file handle for the named file in the translation unit tu,
## or a NULL file handle if the file was not a part of this translation unit.
proc clang_getFile*(tu :CXTranslationUnit; file_name :cstring) :CXFile {.importc:"clang_getFile", cdecl, dynlib:libclang.}
## 
## Retrieve the buffer associated with the given file.
## 
## \param tu the translation unit
## 
## \param file the file for which to retrieve the buffer.
## 
## \param size [out] if non-NULL, will be set to the size of the buffer.
## 
## \returns a pointer to the buffer in memory that holds the contents of
## file, or a NULL pointer when the file is not loaded.
proc clang_getFileContents*(tu :CXTranslationUnit; file :CXFile; size :ptr csize_t) :cstring {.importc:"clang_getFileContents", cdecl, dynlib:libclang.}
## 
## Retrieves the source location associated with a given file/line/column
## in a particular translation unit.
proc clang_getLocation*(tu :CXTranslationUnit; file :CXFile; line :cuint; column :cuint) :CXSourceLocation {.importc:"clang_getLocation", cdecl, dynlib:libclang.}
## 
## Retrieves the source location associated with a given character offset
## in a particular translation unit.
proc clang_getLocationForOffset*(tu :CXTranslationUnit; file :CXFile; offset :cuint) :CXSourceLocation {.importc:"clang_getLocationForOffset", cdecl, dynlib:libclang.}
## 
## Retrieve all ranges that were skipped by the preprocessor.
## 
## The preprocessor will skip lines when they are surrounded by an
## if/ifdef/ifndef directive whose condition does not evaluate to true.
proc clang_getSkippedRanges*(tu :CXTranslationUnit; file :CXFile) :ptr CXSourceRangeList {.importc:"clang_getSkippedRanges", cdecl, dynlib:libclang.}
## 
## Retrieve all ranges from all files that were skipped by the
## preprocessor.
## 
## The preprocessor will skip lines when they are surrounded by an
## if/ifdef/ifndef directive whose condition does not evaluate to true.
proc clang_getAllSkippedRanges*(tu :CXTranslationUnit) :ptr CXSourceRangeList {.importc:"clang_getAllSkippedRanges", cdecl, dynlib:libclang.}
## 
## Determine the number of diagnostics produced for the given
## translation unit.
proc clang_getNumDiagnostics*(Unit :CXTranslationUnit) :cuint {.importc:"clang_getNumDiagnostics", cdecl, dynlib:libclang.}
## 
## Retrieve a diagnostic associated with the given translation unit.
## 
## \param Unit the translation unit to query.
## \param Index the zero-based diagnostic number to retrieve.
## 
## \returns the requested diagnostic. This diagnostic must be freed
## via a call to clang_disposeDiagnostic().
proc clang_getDiagnostic*(Unit :CXTranslationUnit; Index :cuint) :CXDiagnostic {.importc:"clang_getDiagnostic", cdecl, dynlib:libclang.}
## 
## Retrieve the complete set of diagnostics associated with a
##        translation unit.
## 
## \param Unit the translation unit to query.
proc clang_getDiagnosticSetFromTU*(Unit :CXTranslationUnit) :CXDiagnosticSet {.importc:"clang_getDiagnosticSetFromTU", cdecl, dynlib:libclang.}
## 
## Get the original translation unit source file name.
proc clang_getTranslationUnitSpelling*(CTUnit :CXTranslationUnit) :CXString {.importc:"clang_getTranslationUnitSpelling", cdecl, dynlib:libclang.}
## 
## Return the CXTranslationUnit for a given source file and the provided
## command line arguments one would pass to the compiler.
## 
## Note: The 'source_filename' argument is optional.  If the caller provides a
## NULL pointer, the name of the source file is expected to reside in the
## specified command line arguments.
## 
## Note: When encountered in 'clang_command_line_args', the following options
## are ignored:
## 
##   '-c'
##   '-emit-ast'
##   '-fsyntax-only'
##   '-o \<output file>'  (both '-o' and '\<output file>' are ignored)
## 
## \param CIdx The index object with which the translation unit will be
## associated.
## 
## \param source_filename The name of the source file to load, or NULL if the
## source file is included in clang_command_line_args.
## 
## \param num_clang_command_line_args The number of command-line arguments in
## clang_command_line_args.
## 
## \param clang_command_line_args The command-line arguments that would be
## passed to the clang executable if it were being invoked out-of-process.
## These command-line options will be parsed and will affect how the translation
## unit is parsed. Note that the following options are ignored: '-c',
## '-emit-ast', '-fsyntax-only' (which is the default), and '-o \<output file>'.
## 
## \param num_unsaved_files the number of unsaved file entries in \p
## unsaved_files.
## 
## \param unsaved_files the files that have not yet been saved to disk
## but may be required for code completion, including the contents of
## those files.  The contents and name of these files (as specified by
## CXUnsavedFile) are copied when necessary, so the client only needs to
## guarantee their validity until the call to this function returns.
proc clang_createTranslationUnitFromSourceFile*(CIdx :CXIndex; source_filename :cstring; num_clang_command_line_args :cint; clang_command_line_args :ptr cstring; num_unsaved_files :cuint; unsaved_files :ptr struct_CXUnsavedFile) :CXTranslationUnit {.importc:"clang_createTranslationUnitFromSourceFile", cdecl, dynlib:libclang.}
## 
## Same as clang_createTranslationUnit2, but returns
## the CXTranslationUnit instead of an error code.  In case of an error this
## routine returns a NULL CXTranslationUnit, without further detailed
## error codes.
proc clang_createTranslationUnit*(CIdx :CXIndex; ast_filename :cstring) :CXTranslationUnit {.importc:"clang_createTranslationUnit", cdecl, dynlib:libclang.}
## 
## Create a translation unit from an AST file (-emit-ast).
## 
## \param[out] out_TU A non-NULL pointer to store the created
## CXTranslationUnit.
## 
## \returns Zero on success, otherwise returns an error code.
proc clang_createTranslationUnit2*(CIdx :CXIndex; ast_filename :cstring; out_TU :ptr CXTranslationUnit) :CXErrorCode {.importc:"clang_createTranslationUnit2", cdecl, dynlib:libclang.}
## 
## Flags that control the creation of translation units.
## 
## The enumerators in this enumeration type are meant to be bitwise
## ORed together to specify which options should be used when
## constructing the translation unit.
type enum_CXTranslationUnit_Flags* = cint
const
  CXTranslationUnit_None* :enum_CXTranslationUnit_Flags= 0
  CXTranslationUnit_DetailedPreprocessingRecord* :enum_CXTranslationUnit_Flags= 1
  CXTranslationUnit_Incomplete* :enum_CXTranslationUnit_Flags= 2
  CXTranslationUnit_PrecompiledPreamble* :enum_CXTranslationUnit_Flags= 4
  CXTranslationUnit_CacheCompletionResults* :enum_CXTranslationUnit_Flags= 8
  CXTranslationUnit_ForSerialization* :enum_CXTranslationUnit_Flags= 16
  CXTranslationUnit_CXXChainedPCH* :enum_CXTranslationUnit_Flags= 32
  CXTranslationUnit_SkipFunctionBodies* :enum_CXTranslationUnit_Flags= 64
  CXTranslationUnit_IncludeBriefCommentsInCodeCompletion* :enum_CXTranslationUnit_Flags= 128
  CXTranslationUnit_CreatePreambleOnFirstParse* :enum_CXTranslationUnit_Flags= 256
  CXTranslationUnit_KeepGoing* :enum_CXTranslationUnit_Flags= 512
  CXTranslationUnit_SingleFileParse* :enum_CXTranslationUnit_Flags= 1024
  CXTranslationUnit_LimitSkipFunctionBodiesToPreamble* :enum_CXTranslationUnit_Flags= 2048
  CXTranslationUnit_IncludeAttributedTypes* :enum_CXTranslationUnit_Flags= 4096
  CXTranslationUnit_VisitImplicitAttributes* :enum_CXTranslationUnit_Flags= 8192
  CXTranslationUnit_IgnoreNonErrorsFromIncludedFiles* :enum_CXTranslationUnit_Flags= 16384
  CXTranslationUnit_RetainExcludedConditionalBlocks* :enum_CXTranslationUnit_Flags= 32768
type CXTranslationUnit_Flags* = enum_CXTranslationUnit_Flags
## 
## Returns the set of flags that is suitable for parsing a translation
## unit that is being edited.
## 
## The set of flags returned provide options for clang_parseTranslationUnit()
## to indicate that the translation unit is likely to be reparsed many times,
## either explicitly (via clang_reparseTranslationUnit()) or implicitly
## (e.g., by code completion (clang_codeCompletionAt())). The returned flag
## set contains an unspecified set of optimizations (e.g., the precompiled
## preamble) geared toward improving the performance of these routines. The
## set of optimizations enabled may change from one version to the next.
proc clang_defaultEditingTranslationUnitOptions*() :cuint {.importc:"clang_defaultEditingTranslationUnitOptions", cdecl, dynlib:libclang.}
## 
## Same as clang_parseTranslationUnit2, but returns
## the CXTranslationUnit instead of an error code.  In case of an error this
## routine returns a NULL CXTranslationUnit, without further detailed
## error codes.
proc clang_parseTranslationUnit*(CIdx :CXIndex; source_filename :cstring; command_line_args :ptr cstring; num_command_line_args :cint; unsaved_files :ptr struct_CXUnsavedFile; num_unsaved_files :cuint; options :cuint) :CXTranslationUnit {.importc:"clang_parseTranslationUnit", cdecl, dynlib:libclang.}
## 
## Parse the given source file and the translation unit corresponding
## to that file.
## 
## This routine is the main entry point for the Clang C API, providing the
## ability to parse a source file into a translation unit that can then be
## queried by other functions in the API. This routine accepts a set of
## command-line arguments so that the compilation can be configured in the same
## way that the compiler is configured on the command line.
## 
## \param CIdx The index object with which the translation unit will be
## associated.
## 
## \param source_filename The name of the source file to load, or NULL if the
## source file is included in command_line_args.
## 
## \param command_line_args The command-line arguments that would be
## passed to the clang executable if it were being invoked out-of-process.
## These command-line options will be parsed and will affect how the translation
## unit is parsed. Note that the following options are ignored: '-c',
## '-emit-ast', '-fsyntax-only' (which is the default), and '-o \<output file>'.
## 
## \param num_command_line_args The number of command-line arguments in
## command_line_args.
## 
## \param unsaved_files the files that have not yet been saved to disk
## but may be required for parsing, including the contents of
## those files.  The contents and name of these files (as specified by
## CXUnsavedFile) are copied when necessary, so the client only needs to
## guarantee their validity until the call to this function returns.
## 
## \param num_unsaved_files the number of unsaved file entries in \p
## unsaved_files.
## 
## \param options A bitmask of options that affects how the translation unit
## is managed but not its compilation. This should be a bitwise OR of the
## CXTranslationUnit_XXX flags.
## 
## \param[out] out_TU A non-NULL pointer to store the created
## CXTranslationUnit, describing the parsed code and containing any
## diagnostics produced by the compiler.
## 
## \returns Zero on success, otherwise returns an error code.
proc clang_parseTranslationUnit2*(CIdx :CXIndex; source_filename :cstring; command_line_args :ptr cstring; num_command_line_args :cint; unsaved_files :ptr struct_CXUnsavedFile; num_unsaved_files :cuint; options :cuint; out_TU :ptr CXTranslationUnit) :CXErrorCode {.importc:"clang_parseTranslationUnit2", cdecl, dynlib:libclang.}
## 
## Same as clang_parseTranslationUnit2 but requires a full command line
## for command_line_args including argv[0]. This is useful if the standard
## library paths are relative to the binary.
proc clang_parseTranslationUnit2FullArgv*(CIdx :CXIndex; source_filename :cstring; command_line_args :ptr cstring; num_command_line_args :cint; unsaved_files :ptr struct_CXUnsavedFile; num_unsaved_files :cuint; options :cuint; out_TU :ptr CXTranslationUnit) :CXErrorCode {.importc:"clang_parseTranslationUnit2FullArgv", cdecl, dynlib:libclang.}
## 
## Flags that control how translation units are saved.
## 
## The enumerators in this enumeration type are meant to be bitwise
## ORed together to specify which options should be used when
## saving the translation unit.
type enum_CXSaveTranslationUnit_Flags* = cint
const CXSaveTranslationUnit_None* :enum_CXSaveTranslationUnit_Flags= 0
type CXSaveTranslationUnit_Flags* = enum_CXSaveTranslationUnit_Flags
## 
## Returns the set of flags that is suitable for saving a translation
## unit.
## 
## The set of flags returned provide options for
## clang_saveTranslationUnit() by default. The returned flag
## set contains an unspecified set of options that save translation units with
## the most commonly-requested data.
proc clang_defaultSaveOptions*(TU :CXTranslationUnit) :cuint {.importc:"clang_defaultSaveOptions", cdecl, dynlib:libclang.}
## 
## Describes the kind of error that occurred (if any) in a call to
## clang_saveTranslationUnit().
type enum_CXSaveError* = cint
const
  CXSaveError_None* :enum_CXSaveError= 0
  CXSaveError_Unknown* :enum_CXSaveError= 1
  CXSaveError_TranslationErrors* :enum_CXSaveError= 2
  CXSaveError_InvalidTU* :enum_CXSaveError= 3
type CXSaveError* = enum_CXSaveError
## 
## Saves a translation unit into a serialized representation of
## that translation unit on disk.
## 
## Any translation unit that was parsed without error can be saved
## into a file. The translation unit can then be deserialized into a
## new CXTranslationUnit with clang_createTranslationUnit() or,
## if it is an incomplete translation unit that corresponds to a
## header, used as a precompiled header when parsing other translation
## units.
## 
## \param TU The translation unit to save.
## 
## \param FileName The file to which the translation unit will be saved.
## 
## \param options A bitmask of options that affects how the translation unit
## is saved. This should be a bitwise OR of the
## CXSaveTranslationUnit_XXX flags.
## 
## \returns A value that will match one of the enumerators of the CXSaveError
## enumeration. Zero (CXSaveError_None) indicates that the translation unit was
## saved successfully, while a non-zero value indicates that a problem occurred.
proc clang_saveTranslationUnit*(TU :CXTranslationUnit; FileName :cstring; options :cuint) :cint {.importc:"clang_saveTranslationUnit", cdecl, dynlib:libclang.}
## 
## Suspend a translation unit in order to free memory associated with it.
## 
## A suspended translation unit uses significantly less memory but on the other
## side does not support any other calls than clang_reparseTranslationUnit
## to resume it or clang_disposeTranslationUnit to dispose it completely.
proc clang_suspendTranslationUnit*(a0 :CXTranslationUnit) :cuint {.importc:"clang_suspendTranslationUnit", cdecl, dynlib:libclang.}
## 
## Destroy the specified CXTranslationUnit object.
proc clang_disposeTranslationUnit*(a0 :CXTranslationUnit) {.importc:"clang_disposeTranslationUnit", cdecl, dynlib:libclang.}
## 
## Flags that control the reparsing of translation units.
## 
## The enumerators in this enumeration type are meant to be bitwise
## ORed together to specify which options should be used when
## reparsing the translation unit.
type enum_CXReparse_Flags* = cint
const CXReparse_None* :enum_CXReparse_Flags= 0
type CXReparse_Flags* = enum_CXReparse_Flags
## 
## Returns the set of flags that is suitable for reparsing a translation
## unit.
## 
## The set of flags returned provide options for
## clang_reparseTranslationUnit() by default. The returned flag
## set contains an unspecified set of optimizations geared toward common uses
## of reparsing. The set of optimizations enabled may change from one version
## to the next.
proc clang_defaultReparseOptions*(TU :CXTranslationUnit) :cuint {.importc:"clang_defaultReparseOptions", cdecl, dynlib:libclang.}
## 
## Reparse the source files that produced this translation unit.
## 
## This routine can be used to re-parse the source files that originally
## created the given translation unit, for example because those source files
## have changed (either on disk or as passed via unsaved_files). The
## source code will be reparsed with the same command-line options as it
## was originally parsed.
## 
## Reparsing a translation unit invalidates all cursors and source locations
## that refer into that translation unit. This makes reparsing a translation
## unit semantically equivalent to destroying the translation unit and then
## creating a new translation unit with the same command-line arguments.
## However, it may be more efficient to reparse a translation
## unit using this routine.
## 
## \param TU The translation unit whose contents will be re-parsed. The
## translation unit must originally have been built with
## clang_createTranslationUnitFromSourceFile().
## 
## \param num_unsaved_files The number of unsaved file entries in \p
## unsaved_files.
## 
## \param unsaved_files The files that have not yet been saved to disk
## but may be required for parsing, including the contents of
## those files.  The contents and name of these files (as specified by
## CXUnsavedFile) are copied when necessary, so the client only needs to
## guarantee their validity until the call to this function returns.
## 
## \param options A bitset of options composed of the flags in CXReparse_Flags.
## The function clang_defaultReparseOptions() produces a default set of
## options recommended for most uses, based on the translation unit.
## 
## \returns 0 if the sources could be reparsed.  A non-zero error code will be
## returned if reparsing was impossible, such that the translation unit is
## invalid. In such cases, the only valid call for TU is
## clang_disposeTranslationUnit(TU).  The error codes returned by this
## routine are described by the CXErrorCode enum.
proc clang_reparseTranslationUnit*(TU :CXTranslationUnit; num_unsaved_files :cuint; unsaved_files :ptr struct_CXUnsavedFile; options :cuint) :cint {.importc:"clang_reparseTranslationUnit", cdecl, dynlib:libclang.}
## 
## Categorizes how memory is being used by a translation unit.
type enum_CXTUResourceUsageKind* = cint
const
  CXTUResourceUsage_AST* :enum_CXTUResourceUsageKind= 1
  CXTUResourceUsage_Identifiers* :enum_CXTUResourceUsageKind= 2
  CXTUResourceUsage_Selectors* :enum_CXTUResourceUsageKind= 3
  CXTUResourceUsage_GlobalCompletionResults* :enum_CXTUResourceUsageKind= 4
  CXTUResourceUsage_SourceManagerContentCache* :enum_CXTUResourceUsageKind= 5
  CXTUResourceUsage_AST_SideTables* :enum_CXTUResourceUsageKind= 6
  CXTUResourceUsage_SourceManager_Membuffer_Malloc* :enum_CXTUResourceUsageKind= 7
  CXTUResourceUsage_SourceManager_Membuffer_MMap* :enum_CXTUResourceUsageKind= 8
  CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc* :enum_CXTUResourceUsageKind= 9
  CXTUResourceUsage_ExternalASTSource_Membuffer_MMap* :enum_CXTUResourceUsageKind= 10
  CXTUResourceUsage_Preprocessor* :enum_CXTUResourceUsageKind= 11
  CXTUResourceUsage_PreprocessingRecord* :enum_CXTUResourceUsageKind= 12
  CXTUResourceUsage_SourceManager_DataStructures* :enum_CXTUResourceUsageKind= 13
  CXTUResourceUsage_Preprocessor_HeaderSearch* :enum_CXTUResourceUsageKind= 14
  CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN* :enum_CXTUResourceUsageKind= 1
  CXTUResourceUsage_MEMORY_IN_BYTES_END* :enum_CXTUResourceUsageKind= 14
  CXTUResourceUsage_First* :enum_CXTUResourceUsageKind= 1
  CXTUResourceUsage_Last* :enum_CXTUResourceUsageKind= 14
type CXTUResourceUsageKind* = enum_CXTUResourceUsageKind
## 
## Returns the human-readable null-terminated C string that represents
##  the name of the memory category.  This string should never be freed.
proc clang_getTUResourceUsageName*(kind :CXTUResourceUsageKind) :cstring {.importc:"clang_getTUResourceUsageName", cdecl, dynlib:libclang.}
type
  rlay object.
Must be disposed* {. with .} = object
    _cre* :ate"///
Create a CXVi
    rtualF* :ileOve
  CXTUResourceUsageEntry* = struct_CXTUResourceUsageEntry
## 
## The memory usage of a CXTranslationUnit, broken into categories.
type
  reserved, always pass 0.* {.clang_.} = object
    clan* :g_Virtu
    alFileOver* :lay_d
    ispose(* :ptr ).

\param options is 
  CXTUResourceUsage* = struct_CXTUResourceUsage
## 
## Return the memory usage of a translation unit.  This object
##  should be released with clang_disposeCXTUResourceUsage().
proc clang_getCXTUResourceUsage*(TU :CXTranslationUnit) :CXTUResourceUsage {.importc:"clang_getCXTUResourceUsage", cdecl, dynlib:libclang.}
proc clang_disposeCXTUResourceUsage*(usage :CXTUResourceUsage) {.importc:"clang_disposeCXTUResourceUsage", cdecl, dynlib:libclang.}
## 
## Get target information for this translation unit.
## 
## The CXTargetInfo object cannot outlive the CXTranslationUnit object.
proc clang_getTranslationUnitTargetInfo*(CTUnit :CXTranslationUnit) :CXTargetInfo {.importc:"clang_getTranslationUnitTargetInfo", cdecl, dynlib:libclang.}
## 
## Destroy the CXTargetInfo object.
proc clang_TargetInfo_dispose*(Info :CXTargetInfo) {.importc:"clang_TargetInfo_dispose", cdecl, dynlib:libclang.}
## 
## Get the normalized target triple as a string.
## 
## Returns the empty string in case of any error.
proc clang_TargetInfo_getTriple*(Info :CXTargetInfo) :CXString {.importc:"clang_TargetInfo_getTriple", cdecl, dynlib:libclang.}
## 
## Get the pointer width of the target in bits.
## 
## Returns -1 in case of error.
proc clang_TargetInfo_getPointerWidth*(Info :CXTargetInfo) :cint {.importc:"clang_TargetInfo_getPointerWidth", cdecl, dynlib:libclang.}
## 
## Describes the kind of entity that a cursor refers to.
type enum_CXCursorKind* = cint
const
  CXCursor_UnexposedDecl* :enum_CXCursorKind= 1
  CXCursor_StructDecl* :enum_CXCursorKind= 2
  CXCursor_UnionDecl* :enum_CXCursorKind= 3
  CXCursor_ClassDecl* :enum_CXCursorKind= 4
  CXCursor_EnumDecl* :enum_CXCursorKind= 5
  CXCursor_FieldDecl* :enum_CXCursorKind= 6
  CXCursor_EnumConstantDecl* :enum_CXCursorKind= 7
  CXCursor_FunctionDecl* :enum_CXCursorKind= 8
  CXCursor_VarDecl* :enum_CXCursorKind= 9
  CXCursor_ParmDecl* :enum_CXCursorKind= 10
  CXCursor_ObjCInterfaceDecl* :enum_CXCursorKind= 11
  CXCursor_ObjCCategoryDecl* :enum_CXCursorKind= 12
  CXCursor_ObjCProtocolDecl* :enum_CXCursorKind= 13
  CXCursor_ObjCPropertyDecl* :enum_CXCursorKind= 14
  CXCursor_ObjCIvarDecl* :enum_CXCursorKind= 15
  CXCursor_ObjCInstanceMethodDecl* :enum_CXCursorKind= 16
  CXCursor_ObjCClassMethodDecl* :enum_CXCursorKind= 17
  CXCursor_ObjCImplementationDecl* :enum_CXCursorKind= 18
  CXCursor_ObjCCategoryImplDecl* :enum_CXCursorKind= 19
  CXCursor_TypedefDecl* :enum_CXCursorKind= 20
  CXCursor_CXXMethod* :enum_CXCursorKind= 21
  CXCursor_Namespace* :enum_CXCursorKind= 22
  CXCursor_LinkageSpec* :enum_CXCursorKind= 23
  CXCursor_Constructor* :enum_CXCursorKind= 24
  CXCursor_Destructor* :enum_CXCursorKind= 25
  CXCursor_ConversionFunction* :enum_CXCursorKind= 26
  CXCursor_TemplateTypeParameter* :enum_CXCursorKind= 27
  CXCursor_NonTypeTemplateParameter* :enum_CXCursorKind= 28
  CXCursor_TemplateTemplateParameter* :enum_CXCursorKind= 29
  CXCursor_FunctionTemplate* :enum_CXCursorKind= 30
  CXCursor_ClassTemplate* :enum_CXCursorKind= 31
  CXCursor_ClassTemplatePartialSpecialization* :enum_CXCursorKind= 32
  CXCursor_NamespaceAlias* :enum_CXCursorKind= 33
  CXCursor_UsingDirective* :enum_CXCursorKind= 34
  CXCursor_UsingDeclaration* :enum_CXCursorKind= 35
  CXCursor_TypeAliasDecl* :enum_CXCursorKind= 36
  CXCursor_ObjCSynthesizeDecl* :enum_CXCursorKind= 37
  CXCursor_ObjCDynamicDecl* :enum_CXCursorKind= 38
  CXCursor_CXXAccessSpecifier* :enum_CXCursorKind= 39
  CXCursor_FirstDecl* :enum_CXCursorKind= 1
  CXCursor_LastDecl* :enum_CXCursorKind= 39
  CXCursor_FirstRef* :enum_CXCursorKind= 40
  CXCursor_ObjCSuperClassRef* :enum_CXCursorKind= 40
  CXCursor_ObjCProtocolRef* :enum_CXCursorKind= 41
  CXCursor_ObjCClassRef* :enum_CXCursorKind= 42
  CXCursor_TypeRef* :enum_CXCursorKind= 43
  CXCursor_CXXBaseSpecifier* :enum_CXCursorKind= 44
  CXCursor_TemplateRef* :enum_CXCursorKind= 45
  CXCursor_NamespaceRef* :enum_CXCursorKind= 46
  CXCursor_MemberRef* :enum_CXCursorKind= 47
  CXCursor_LabelRef* :enum_CXCursorKind= 48
  CXCursor_OverloadedDeclRef* :enum_CXCursorKind= 49
  CXCursor_VariableRef* :enum_CXCursorKind= 50
  CXCursor_LastRef* :enum_CXCursorKind= 50
  CXCursor_FirstInvalid* :enum_CXCursorKind= 70
  CXCursor_InvalidFile* :enum_CXCursorKind= 70
  CXCursor_NoDeclFound* :enum_CXCursorKind= 71
  CXCursor_NotImplemented* :enum_CXCursorKind= 72
  CXCursor_InvalidCode* :enum_CXCursorKind= 73
  CXCursor_LastInvalid* :enum_CXCursorKind= 73
  CXCursor_FirstExpr* :enum_CXCursorKind= 100
  CXCursor_UnexposedExpr* :enum_CXCursorKind= 100
  CXCursor_DeclRefExpr* :enum_CXCursorKind= 101
  CXCursor_MemberRefExpr* :enum_CXCursorKind= 102
  CXCursor_CallExpr* :enum_CXCursorKind= 103
  CXCursor_ObjCMessageExpr* :enum_CXCursorKind= 104
  CXCursor_BlockExpr* :enum_CXCursorKind= 105
  CXCursor_IntegerLiteral* :enum_CXCursorKind= 106
  CXCursor_FloatingLiteral* :enum_CXCursorKind= 107
  CXCursor_ImaginaryLiteral* :enum_CXCursorKind= 108
  CXCursor_StringLiteral* :enum_CXCursorKind= 109
  CXCursor_CharacterLiteral* :enum_CXCursorKind= 110
  CXCursor_ParenExpr* :enum_CXCursorKind= 111
  CXCursor_UnaryOperator* :enum_CXCursorKind= 112
  CXCursor_ArraySubscriptExpr* :enum_CXCursorKind= 113
  CXCursor_BinaryOperator* :enum_CXCursorKind= 114
  CXCursor_CompoundAssignOperator* :enum_CXCursorKind= 115
  CXCursor_ConditionalOperator* :enum_CXCursorKind= 116
  CXCursor_CStyleCastExpr* :enum_CXCursorKind= 117
  CXCursor_CompoundLiteralExpr* :enum_CXCursorKind= 118
  CXCursor_InitListExpr* :enum_CXCursorKind= 119
  CXCursor_AddrLabelExpr* :enum_CXCursorKind= 120
  CXCursor_StmtExpr* :enum_CXCursorKind= 121
  CXCursor_GenericSelectionExpr* :enum_CXCursorKind= 122
  CXCursor_GNUNullExpr* :enum_CXCursorKind= 123
  CXCursor_CXXStaticCastExpr* :enum_CXCursorKind= 124
  CXCursor_CXXDynamicCastExpr* :enum_CXCursorKind= 125
  CXCursor_CXXReinterpretCastExpr* :enum_CXCursorKind= 126
  CXCursor_CXXConstCastExpr* :enum_CXCursorKind= 127
  CXCursor_CXXFunctionalCastExpr* :enum_CXCursorKind= 128
  CXCursor_CXXTypeidExpr* :enum_CXCursorKind= 129
  CXCursor_CXXBoolLiteralExpr* :enum_CXCursorKind= 130
  CXCursor_CXXNullPtrLiteralExpr* :enum_CXCursorKind= 131
  CXCursor_CXXThisExpr* :enum_CXCursorKind= 132
  CXCursor_CXXThrowExpr* :enum_CXCursorKind= 133
  CXCursor_CXXNewExpr* :enum_CXCursorKind= 134
  CXCursor_CXXDeleteExpr* :enum_CXCursorKind= 135
  CXCursor_UnaryExpr* :enum_CXCursorKind= 136
  CXCursor_ObjCStringLiteral* :enum_CXCursorKind= 137
  CXCursor_ObjCEncodeExpr* :enum_CXCursorKind= 138
  CXCursor_ObjCSelectorExpr* :enum_CXCursorKind= 139
  CXCursor_ObjCProtocolExpr* :enum_CXCursorKind= 140
  CXCursor_ObjCBridgedCastExpr* :enum_CXCursorKind= 141
  CXCursor_PackExpansionExpr* :enum_CXCursorKind= 142
  CXCursor_SizeOfPackExpr* :enum_CXCursorKind= 143
  CXCursor_LambdaExpr* :enum_CXCursorKind= 144
  CXCursor_ObjCBoolLiteralExpr* :enum_CXCursorKind= 145
  CXCursor_ObjCSelfExpr* :enum_CXCursorKind= 146
  CXCursor_OMPArraySectionExpr* :enum_CXCursorKind= 147
  CXCursor_ObjCAvailabilityCheckExpr* :enum_CXCursorKind= 148
  CXCursor_FixedPointLiteral* :enum_CXCursorKind= 149
  CXCursor_OMPArrayShapingExpr* :enum_CXCursorKind= 150
  CXCursor_OMPIteratorExpr* :enum_CXCursorKind= 151
  CXCursor_CXXAddrspaceCastExpr* :enum_CXCursorKind= 152
  CXCursor_ConceptSpecializationExpr* :enum_CXCursorKind= 153
  CXCursor_RequiresExpr* :enum_CXCursorKind= 154
  CXCursor_CXXParenListInitExpr* :enum_CXCursorKind= 155
  CXCursor_LastExpr* :enum_CXCursorKind= 155
  CXCursor_FirstStmt* :enum_CXCursorKind= 200
  CXCursor_UnexposedStmt* :enum_CXCursorKind= 200
  CXCursor_LabelStmt* :enum_CXCursorKind= 201
  CXCursor_CompoundStmt* :enum_CXCursorKind= 202
  CXCursor_CaseStmt* :enum_CXCursorKind= 203
  CXCursor_DefaultStmt* :enum_CXCursorKind= 204
  CXCursor_IfStmt* :enum_CXCursorKind= 205
  CXCursor_SwitchStmt* :enum_CXCursorKind= 206
  CXCursor_WhileStmt* :enum_CXCursorKind= 207
  CXCursor_DoStmt* :enum_CXCursorKind= 208
  CXCursor_ForStmt* :enum_CXCursorKind= 209
  CXCursor_GotoStmt* :enum_CXCursorKind= 210
  CXCursor_IndirectGotoStmt* :enum_CXCursorKind= 211
  CXCursor_ContinueStmt* :enum_CXCursorKind= 212
  CXCursor_BreakStmt* :enum_CXCursorKind= 213
  CXCursor_ReturnStmt* :enum_CXCursorKind= 214
  CXCursor_GCCAsmStmt* :enum_CXCursorKind= 215
  CXCursor_AsmStmt* :enum_CXCursorKind= 215
  CXCursor_ObjCAtTryStmt* :enum_CXCursorKind= 216
  CXCursor_ObjCAtCatchStmt* :enum_CXCursorKind= 217
  CXCursor_ObjCAtFinallyStmt* :enum_CXCursorKind= 218
  CXCursor_ObjCAtThrowStmt* :enum_CXCursorKind= 219
  CXCursor_ObjCAtSynchronizedStmt* :enum_CXCursorKind= 220
  CXCursor_ObjCAutoreleasePoolStmt* :enum_CXCursorKind= 221
  CXCursor_ObjCForCollectionStmt* :enum_CXCursorKind= 222
  CXCursor_CXXCatchStmt* :enum_CXCursorKind= 223
  CXCursor_CXXTryStmt* :enum_CXCursorKind= 224
  CXCursor_CXXForRangeStmt* :enum_CXCursorKind= 225
  CXCursor_SEHTryStmt* :enum_CXCursorKind= 226
  CXCursor_SEHExceptStmt* :enum_CXCursorKind= 227
  CXCursor_SEHFinallyStmt* :enum_CXCursorKind= 228
  CXCursor_MSAsmStmt* :enum_CXCursorKind= 229
  CXCursor_NullStmt* :enum_CXCursorKind= 230
  CXCursor_DeclStmt* :enum_CXCursorKind= 231
  CXCursor_OMPParallelDirective* :enum_CXCursorKind= 232
  CXCursor_OMPSimdDirective* :enum_CXCursorKind= 233
  CXCursor_OMPForDirective* :enum_CXCursorKind= 234
  CXCursor_OMPSectionsDirective* :enum_CXCursorKind= 235
  CXCursor_OMPSectionDirective* :enum_CXCursorKind= 236
  CXCursor_OMPSingleDirective* :enum_CXCursorKind= 237
  CXCursor_OMPParallelForDirective* :enum_CXCursorKind= 238
  CXCursor_OMPParallelSectionsDirective* :enum_CXCursorKind= 239
  CXCursor_OMPTaskDirective* :enum_CXCursorKind= 240
  CXCursor_OMPMasterDirective* :enum_CXCursorKind= 241
  CXCursor_OMPCriticalDirective* :enum_CXCursorKind= 242
  CXCursor_OMPTaskyieldDirective* :enum_CXCursorKind= 243
  CXCursor_OMPBarrierDirective* :enum_CXCursorKind= 244
  CXCursor_OMPTaskwaitDirective* :enum_CXCursorKind= 245
  CXCursor_OMPFlushDirective* :enum_CXCursorKind= 246
  CXCursor_SEHLeaveStmt* :enum_CXCursorKind= 247
  CXCursor_OMPOrderedDirective* :enum_CXCursorKind= 248
  CXCursor_OMPAtomicDirective* :enum_CXCursorKind= 249
  CXCursor_OMPForSimdDirective* :enum_CXCursorKind= 250
  CXCursor_OMPParallelForSimdDirective* :enum_CXCursorKind= 251
  CXCursor_OMPTargetDirective* :enum_CXCursorKind= 252
  CXCursor_OMPTeamsDirective* :enum_CXCursorKind= 253
  CXCursor_OMPTaskgroupDirective* :enum_CXCursorKind= 254
  CXCursor_OMPCancellationPointDirective* :enum_CXCursorKind= 255
  CXCursor_OMPCancelDirective* :enum_CXCursorKind= 256
  CXCursor_OMPTargetDataDirective* :enum_CXCursorKind= 257
  CXCursor_OMPTaskLoopDirective* :enum_CXCursorKind= 258
  CXCursor_OMPTaskLoopSimdDirective* :enum_CXCursorKind= 259
  CXCursor_OMPDistributeDirective* :enum_CXCursorKind= 260
  CXCursor_OMPTargetEnterDataDirective* :enum_CXCursorKind= 261
  CXCursor_OMPTargetExitDataDirective* :enum_CXCursorKind= 262
  CXCursor_OMPTargetParallelDirective* :enum_CXCursorKind= 263
  CXCursor_OMPTargetParallelForDirective* :enum_CXCursorKind= 264
  CXCursor_OMPTargetUpdateDirective* :enum_CXCursorKind= 265
  CXCursor_OMPDistributeParallelForDirective* :enum_CXCursorKind= 266
  CXCursor_OMPDistributeParallelForSimdDirective* :enum_CXCursorKind= 267
  CXCursor_OMPDistributeSimdDirective* :enum_CXCursorKind= 268
  CXCursor_OMPTargetParallelForSimdDirective* :enum_CXCursorKind= 269
  CXCursor_OMPTargetSimdDirective* :enum_CXCursorKind= 270
  CXCursor_OMPTeamsDistributeDirective* :enum_CXCursorKind= 271
  CXCursor_OMPTeamsDistributeSimdDirective* :enum_CXCursorKind= 272
  CXCursor_OMPTeamsDistributeParallelForSimdDirective* :enum_CXCursorKind= 273
  CXCursor_OMPTeamsDistributeParallelForDirective* :enum_CXCursorKind= 274
  CXCursor_OMPTargetTeamsDirective* :enum_CXCursorKind= 275
  CXCursor_OMPTargetTeamsDistributeDirective* :enum_CXCursorKind= 276
  CXCursor_OMPTargetTeamsDistributeParallelForDirective* :enum_CXCursorKind= 277
  CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective* :enum_CXCursorKind= 278
  CXCursor_OMPTargetTeamsDistributeSimdDirective* :enum_CXCursorKind= 279
  CXCursor_BuiltinBitCastExpr* :enum_CXCursorKind= 280
  CXCursor_OMPMasterTaskLoopDirective* :enum_CXCursorKind= 281
  CXCursor_OMPParallelMasterTaskLoopDirective* :enum_CXCursorKind= 282
  CXCursor_OMPMasterTaskLoopSimdDirective* :enum_CXCursorKind= 283
  CXCursor_OMPParallelMasterTaskLoopSimdDirective* :enum_CXCursorKind= 284
  CXCursor_OMPParallelMasterDirective* :enum_CXCursorKind= 285
  CXCursor_OMPDepobjDirective* :enum_CXCursorKind= 286
  CXCursor_OMPScanDirective* :enum_CXCursorKind= 287
  CXCursor_OMPTileDirective* :enum_CXCursorKind= 288
  CXCursor_OMPCanonicalLoop* :enum_CXCursorKind= 289
  CXCursor_OMPInteropDirective* :enum_CXCursorKind= 290
  CXCursor_OMPDispatchDirective* :enum_CXCursorKind= 291
  CXCursor_OMPMaskedDirective* :enum_CXCursorKind= 292
  CXCursor_OMPUnrollDirective* :enum_CXCursorKind= 293
  CXCursor_OMPMetaDirective* :enum_CXCursorKind= 294
  CXCursor_OMPGenericLoopDirective* :enum_CXCursorKind= 295
  CXCursor_OMPTeamsGenericLoopDirective* :enum_CXCursorKind= 296
  CXCursor_OMPTargetTeamsGenericLoopDirective* :enum_CXCursorKind= 297
  CXCursor_OMPParallelGenericLoopDirective* :enum_CXCursorKind= 298
  CXCursor_OMPTargetParallelGenericLoopDirective* :enum_CXCursorKind= 299
  CXCursor_OMPParallelMaskedDirective* :enum_CXCursorKind= 300
  CXCursor_OMPMaskedTaskLoopDirective* :enum_CXCursorKind= 301
  CXCursor_OMPMaskedTaskLoopSimdDirective* :enum_CXCursorKind= 302
  CXCursor_OMPParallelMaskedTaskLoopDirective* :enum_CXCursorKind= 303
  CXCursor_OMPParallelMaskedTaskLoopSimdDirective* :enum_CXCursorKind= 304
  CXCursor_OMPErrorDirective* :enum_CXCursorKind= 305
  CXCursor_OMPScopeDirective* :enum_CXCursorKind= 306
  CXCursor_LastStmt* :enum_CXCursorKind= 306
  CXCursor_TranslationUnit* :enum_CXCursorKind= 350
  CXCursor_FirstAttr* :enum_CXCursorKind= 400
  CXCursor_UnexposedAttr* :enum_CXCursorKind= 400
  CXCursor_IBActionAttr* :enum_CXCursorKind= 401
  CXCursor_IBOutletAttr* :enum_CXCursorKind= 402
  CXCursor_IBOutletCollectionAttr* :enum_CXCursorKind= 403
  CXCursor_CXXFinalAttr* :enum_CXCursorKind= 404
  CXCursor_CXXOverrideAttr* :enum_CXCursorKind= 405
  CXCursor_AnnotateAttr* :enum_CXCursorKind= 406
  CXCursor_AsmLabelAttr* :enum_CXCursorKind= 407
  CXCursor_PackedAttr* :enum_CXCursorKind= 408
  CXCursor_PureAttr* :enum_CXCursorKind= 409
  CXCursor_ConstAttr* :enum_CXCursorKind= 410
  CXCursor_NoDuplicateAttr* :enum_CXCursorKind= 411
  CXCursor_CUDAConstantAttr* :enum_CXCursorKind= 412
  CXCursor_CUDADeviceAttr* :enum_CXCursorKind= 413
  CXCursor_CUDAGlobalAttr* :enum_CXCursorKind= 414
  CXCursor_CUDAHostAttr* :enum_CXCursorKind= 415
  CXCursor_CUDASharedAttr* :enum_CXCursorKind= 416
  CXCursor_VisibilityAttr* :enum_CXCursorKind= 417
  CXCursor_DLLExport* :enum_CXCursorKind= 418
  CXCursor_DLLImport* :enum_CXCursorKind= 419
  CXCursor_NSReturnsRetained* :enum_CXCursorKind= 420
  CXCursor_NSReturnsNotRetained* :enum_CXCursorKind= 421
  CXCursor_NSReturnsAutoreleased* :enum_CXCursorKind= 422
  CXCursor_NSConsumesSelf* :enum_CXCursorKind= 423
  CXCursor_NSConsumed* :enum_CXCursorKind= 424
  CXCursor_ObjCException* :enum_CXCursorKind= 425
  CXCursor_ObjCNSObject* :enum_CXCursorKind= 426
  CXCursor_ObjCIndependentClass* :enum_CXCursorKind= 427
  CXCursor_ObjCPreciseLifetime* :enum_CXCursorKind= 428
  CXCursor_ObjCReturnsInnerPointer* :enum_CXCursorKind= 429
  CXCursor_ObjCRequiresSuper* :enum_CXCursorKind= 430
  CXCursor_ObjCRootClass* :enum_CXCursorKind= 431
  CXCursor_ObjCSubclassingRestricted* :enum_CXCursorKind= 432
  CXCursor_ObjCExplicitProtocolImpl* :enum_CXCursorKind= 433
  CXCursor_ObjCDesignatedInitializer* :enum_CXCursorKind= 434
  CXCursor_ObjCRuntimeVisible* :enum_CXCursorKind= 435
  CXCursor_ObjCBoxable* :enum_CXCursorKind= 436
  CXCursor_FlagEnum* :enum_CXCursorKind= 437
  CXCursor_ConvergentAttr* :enum_CXCursorKind= 438
  CXCursor_WarnUnusedAttr* :enum_CXCursorKind= 439
  CXCursor_WarnUnusedResultAttr* :enum_CXCursorKind= 440
  CXCursor_AlignedAttr* :enum_CXCursorKind= 441
  CXCursor_LastAttr* :enum_CXCursorKind= 441
  CXCursor_PreprocessingDirective* :enum_CXCursorKind= 500
  CXCursor_MacroDefinition* :enum_CXCursorKind= 501
  CXCursor_MacroExpansion* :enum_CXCursorKind= 502
  CXCursor_MacroInstantiation* :enum_CXCursorKind= 502
  CXCursor_InclusionDirective* :enum_CXCursorKind= 503
  CXCursor_FirstPreprocessing* :enum_CXCursorKind= 500
  CXCursor_LastPreprocessing* :enum_CXCursorKind= 503
  CXCursor_ModuleImportDecl* :enum_CXCursorKind= 600
  CXCursor_TypeAliasTemplateDecl* :enum_CXCursorKind= 601
  CXCursor_StaticAssert* :enum_CXCursorKind= 602
  CXCursor_FriendDecl* :enum_CXCursorKind= 603
  CXCursor_ConceptDecl* :enum_CXCursorKind= 604
  CXCursor_FirstExtraDecl* :enum_CXCursorKind= 600
  CXCursor_LastExtraDecl* :enum_CXCursorKind= 604
  CXCursor_OverloadCandidate* :enum_CXCursorKind= 700
type CXCursorKind* = enum_CXCursorKind
## 
## A cursor representing some element in the abstract syntax tree for
## a translation unit.
## 
## The cursor abstraction unifies the different kinds of entities in a
## program--declaration, statements, expressions, references to declarations,
## etc.--under a single "cursor" abstraction with a common set of operations.
## Common operation for a cursor include: getting the physical location in
## a source file where the cursor points, getting the name associated with a
## cursor, and retrieving cursors for any child nodes of a particular cursor.
## 
## Cursors can be produced in two specific ways.
## clang_getTranslationUnitCursor() produces a cursor for a translation unit,
## from which one can use clang_visitChildren() to explore the rest of the
## translation unit. clang_getCursor() maps from a physical source location
## to the entity that resides at that location, allowing one to map from the
## source code into the AST.
type rorCodea* {.0CXVir.} = object
  Virt* :ualFileOverl
  ay_ad* :dFil
  eMap* :array[r, pingCXE]
## 
## Retrieve the NULL cursor, which represents no entity.
proc clang_getNullCursor*() :CXCursor {.importc:"clang_getNullCursor", cdecl, dynlib:libclang.}
## 
## Retrieve the cursor that represents the given translation unit.
## 
## The translation unit cursor can be used to start traversing the
## various declarations within the given translation unit.
proc clang_getTranslationUnitCursor*(a0 :CXTranslationUnit) :CXCursor {.importc:"clang_getTranslationUnitCursor", cdecl, dynlib:libclang.}
## 
## Determine whether two cursors are equivalent.
proc clang_equalCursors*(a0 :CXCursor; a1 :CXCursor) :cuint {.importc:"clang_equalCursors", cdecl, dynlib:libclang.}
## 
## Returns non-zero if cursor is null.
proc clang_Cursor_isNull*(cursor :CXCursor) :cint {.importc:"clang_Cursor_isNull", cdecl, dynlib:libclang.}
## 
## Compute a hash value for the given cursor.
proc clang_hashCursor*(a0 :CXCursor) :cuint {.importc:"clang_hashCursor", cdecl, dynlib:libclang.}
## 
## Retrieve the kind of the given cursor.
proc clang_getCursorKind*(a0 :CXCursor) :CXCursorKind {.importc:"clang_getCursorKind", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor kind represents a declaration.
proc clang_isDeclaration*(a0 :CXCursorKind) :cuint {.importc:"clang_isDeclaration", cdecl, dynlib:libclang.}
## 
## Determine whether the given declaration is invalid.
## 
## A declaration is invalid if it could not be parsed successfully.
## 
## \returns non-zero if the cursor represents a declaration and it is
## invalid, otherwise NULL.
proc clang_isInvalidDeclaration*(a0 :CXCursor) :cuint {.importc:"clang_isInvalidDeclaration", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor kind represents a simple
## reference.
## 
## Note that other kinds of cursors (such as expressions) can also refer to
## other cursors. Use clang_getCursorReferenced() to determine whether a
## particular cursor refers to another entity.
proc clang_isReference*(a0 :CXCursorKind) :cuint {.importc:"clang_isReference", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor kind represents an expression.
proc clang_isExpression*(a0 :CXCursorKind) :cuint {.importc:"clang_isExpression", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor kind represents a statement.
proc clang_isStatement*(a0 :CXCursorKind) :cuint {.importc:"clang_isStatement", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor kind represents an attribute.
proc clang_isAttribute*(a0 :CXCursorKind) :cuint {.importc:"clang_isAttribute", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor has any attributes.
proc clang_Cursor_hasAttrs*(C :CXCursor) :cuint {.importc:"clang_Cursor_hasAttrs", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor kind represents an invalid
## cursor.
proc clang_isInvalid*(a0 :CXCursorKind) :cuint {.importc:"clang_isInvalid", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor kind represents a translation
## unit.
proc clang_isTranslationUnit*(a0 :CXCursorKind) :cuint {.importc:"clang_isTranslationUnit", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor represents a preprocessing
## element, such as a preprocessor directive or macro instantiation.
proc clang_isPreprocessing*(a0 :CXCursorKind) :cuint {.importc:"clang_isPreprocessing", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor represents a currently
##  unexposed piece of the AST (e.g., CXCursor_UnexposedStmt).
proc clang_isUnexposed*(a0 :CXCursorKind) :cuint {.importc:"clang_isUnexposed", cdecl, dynlib:libclang.}
## 
## Describe the linkage of the entity referred to by a cursor.
type enum_CXLinkageKind* = cint
const
  CXLinkage_Invalid* :enum_CXLinkageKind= 0
  CXLinkage_NoLinkage* :enum_CXLinkageKind= 1
  CXLinkage_Internal* :enum_CXLinkageKind= 2
  CXLinkage_UniqueExternal* :enum_CXLinkageKind= 3
  CXLinkage_External* :enum_CXLinkageKind= 4
type CXLinkageKind* = enum_CXLinkageKind
## 
## Determine the linkage of the entity referred to by a given cursor.
proc clang_getCursorLinkage*(cursor :CXCursor) :CXLinkageKind {.importc:"clang_getCursorLinkage", cdecl, dynlib:libclang.}
type enum_CXVisibilityKind* = cint
const
  CXVisibility_Invalid* :enum_CXVisibilityKind= 0
  CXVisibility_Hidden* :enum_CXVisibilityKind= 1
  CXVisibility_Protected* :enum_CXVisibilityKind= 2
  CXVisibility_Default* :enum_CXVisibilityKind= 3
type CXVisibilityKind* = enum_CXVisibilityKind
## 
## Describe the visibility of the entity referred to by a cursor.
## 
## This returns the default visibility if not explicitly specified by
## a visibility attribute. The default visibility may be changed by
## commandline arguments.
## 
## \param cursor The cursor to query.
## 
## \returns The visibility of the cursor.
proc clang_getCursorVisibility*(cursor :CXCursor) :CXVisibilityKind {.importc:"clang_getCursorVisibility", cdecl, dynlib:libclang.}
## 
## Determine the availability of the entity that this cursor refers to,
## taking the current target platform into account.
## 
## \param cursor The cursor to query.
## 
## \returns The availability of the cursor.
proc clang_getCursorAvailability*(cursor :CXCursor) :CXAvailabilityKind {.importc:"clang_getCursorAvailability", cdecl, dynlib:libclang.}
## 
## Describes the availability of a given entity on a particular platform, e.g.,
## a particular class might only be available on Mac OS 10.7 or newer.
type
  dFileMapping"///
Map an absol* {.ute vi.} = object
    tualFile* :Overlayv
    irtualPath* :cstringre
    alPathcstr* :ingdynlib
    libclangc* :declimpor
    tc"clang_Vi* :rtua
    lFileOv* :erlay_ad
  CXPlatformAvailability* = struct_CXPlatformAvailability
## 
## Determine the availability of the entity that this cursor refers to
## on any platforms for which availability information is known.
## 
## \param cursor The cursor to query.
## 
## \param always_deprecated If non-NULL, will be set to indicate whether the
## entity is deprecated on all platforms.
## 
## \param deprecated_message If non-NULL, will be set to the message text
## provided along with the unconditional deprecation of this entity. The client
## is responsible for deallocating this string.
## 
## \param always_unavailable If non-NULL, will be set to indicate whether the
## entity is unavailable on all platforms.
## 
## \param unavailable_message If non-NULL, will be set to the message text
## provided along with the unconditional unavailability of this entity. The
## client is responsible for deallocating this string.
## 
## \param availability If non-NULL, an array of CXPlatformAvailability instances
## that will be populated with platform availability information, up to either
## the number of platforms for which availability information is available (as
## returned by this function) or availability_size, whichever is smaller.
## 
## \param availability_size The number of elements available in the
## availability array.
## 
## \returns The number of platforms (N) for which availability information is
## available (which is unrelated to availability_size).
## 
## Note that the client is responsible for calling
## clang_disposeCXPlatformAvailability to free each of the
## platform-availability structures returned. There are
## min(N, availability_size) such structures.
proc clang_getCursorPlatformAvailability*(cursor :CXCursor; always_deprecated :ptr cint; deprecated_message :ptr CXString; always_unavailable :ptr cint; unavailable_message :ptr CXString; availability :ptr CXPlatformAvailability; availability_size :cint) :cint {.importc:"clang_getCursorPlatformAvailability", cdecl, dynlib:libclang.}
## 
## Free the memory associated with a CXPlatformAvailability structure.
proc clang_disposeCXPlatformAvailability*(availability :ptr CXPlatformAvailability) {.importc:"clang_disposeCXPlatformAvailability", cdecl, dynlib:libclang.}
## 
## If cursor refers to a variable declaration and it has initializer returns
## cursor referring to the initializer otherwise return null cursor.
proc clang_Cursor_getVarDeclInitializer*(cursor :CXCursor) :CXCursor {.importc:"clang_Cursor_getVarDeclInitializer", cdecl, dynlib:libclang.}
## 
## If cursor refers to a variable declaration that has global storage returns 1.
## If cursor refers to a variable declaration that doesn't have global storage
## returns 0. Otherwise returns -1.
proc clang_Cursor_hasVarDeclGlobalStorage*(cursor :CXCursor) :cint {.importc:"clang_Cursor_hasVarDeclGlobalStorage", cdecl, dynlib:libclang.}
## 
## If cursor refers to a variable declaration that has external storage
## returns 1. If cursor refers to a variable declaration that doesn't have
## external storage returns 0. Otherwise returns -1.
proc clang_Cursor_hasVarDeclExternalStorage*(cursor :CXCursor) :cint {.importc:"clang_Cursor_hasVarDeclExternalStorage", cdecl, dynlib:libclang.}
## 
## Describe the "language" of the entity referred to by a cursor.
type enum_CXLanguageKind* = cint
const
  CXLanguage_Invalid* :enum_CXLanguageKind= 0
  CXLanguage_C* :enum_CXLanguageKind= 1
  CXLanguage_ObjC* :enum_CXLanguageKind= 2
  CXLanguage_CPlusPlus* :enum_CXLanguageKind= 3
type CXLanguageKind* = enum_CXLanguageKind
## 
## Determine the "language" of the entity referred to by a given cursor.
proc clang_getCursorLanguage*(cursor :CXCursor) :CXLanguageKind {.importc:"clang_getCursorLanguage", cdecl, dynlib:libclang.}
## 
## Describe the "thread-local storage (TLS) kind" of the declaration
## referred to by a cursor.
type enum_CXTLSKind* = cint
const
  CXTLS_None* :enum_CXTLSKind= 0
  CXTLS_Dynamic* :enum_CXTLSKind= 1
  CXTLS_Static* :enum_CXTLSKind= 2
type CXTLSKind* = enum_CXTLSKind
## 
## Determine the "thread-local storage (TLS) kind" of the declaration
## referred to by a cursor.
proc clang_getCursorTLSKind*(cursor :CXCursor) :CXTLSKind {.importc:"clang_getCursorTLSKind", cdecl, dynlib:libclang.}
## 
## Returns the translation unit that a cursor originated from.
proc clang_Cursor_getTranslationUnit*(a0 :CXCursor) :CXTranslationUnit {.importc:"clang_Cursor_getTranslationUnit", cdecl, dynlib:libclang.}
type
  struct_CXCursorSetImpl* {.incompleteStruct.} = object
  CXCursorSetImpl* = struct_CXCursorSetImpl
## 
## A fast container representing a set of CXCursors.
type CXCursorSet* = ptr struct_CXCursorSetImpl
## 
## Creates an empty CXCursorSet.
proc clang_createCXCursorSet*() :CXCursorSet {.importc:"clang_createCXCursorSet", cdecl, dynlib:libclang.}
## 
## Disposes a CXCursorSet and releases its associated memory.
proc clang_disposeCXCursorSet*(cset :CXCursorSet) {.importc:"clang_disposeCXCursorSet", cdecl, dynlib:libclang.}
## 
## Queries a CXCursorSet to see if it contains a specific CXCursor.
## 
## \returns non-zero if the set contains the specified cursor.
proc clang_CXCursorSet_contains*(cset :CXCursorSet; cursor :CXCursor) :cuint {.importc:"clang_CXCursorSet_contains", cdecl, dynlib:libclang.}
## 
## Inserts a CXCursor into a CXCursorSet.
## 
## \returns zero if the CXCursor was already in the set, and non-zero otherwise.
proc clang_CXCursorSet_insert*(cset :CXCursorSet; cursor :CXCursor) :cuint {.importc:"clang_CXCursorSet_insert", cdecl, dynlib:libclang.}
## 
## Determine the semantic parent of the given cursor.
## 
## The semantic parent of a cursor is the cursor that semantically contains
## the given cursor. For many declarations, the lexical and semantic parents
## are equivalent (the lexical parent is returned by
## clang_getCursorLexicalParent()). They diverge when declarations or
## definitions are provided out-of-line. For example:
## 
## \code
## class C {
##  void f();
## };
## 
## void C::f() { }
## \endcode
## 
## In the out-of-line definition of C::f, the semantic parent is
## the class C, of which this function is a member. The lexical parent is
## the place where the declaration actually occurs in the source code; in this
## case, the definition occurs in the translation unit. In general, the
## lexical parent for a given entity can change without affecting the semantics
## of the program, and the lexical parent of different declarations of the
## same entity may be different. Changing the semantic parent of a declaration,
## on the other hand, can have a major impact on semantics, and redeclarations
## of a particular entity should all have the same semantic context.
## 
## In the example above, both declarations of C::f have C as their
## semantic context, while the lexical context of the first C::f is C
## and the lexical context of the second C::f is the translation unit.
## 
## For global declarations, the semantic parent is the translation unit.
proc clang_getCursorSemanticParent*(cursor :CXCursor) :CXCursor {.importc:"clang_getCursorSemanticParent", cdecl, dynlib:libclang.}
## 
## Determine the lexical parent of the given cursor.
## 
## The lexical parent of a cursor is the cursor in which the given cursor
## was actually written. For many declarations, the lexical and semantic parents
## are equivalent (the semantic parent is returned by
## clang_getCursorSemanticParent()). They diverge when declarations or
## definitions are provided out-of-line. For example:
## 
## \code
## class C {
##  void f();
## };
## 
## void C::f() { }
## \endcode
## 
## In the out-of-line definition of C::f, the semantic parent is
## the class C, of which this function is a member. The lexical parent is
## the place where the declaration actually occurs in the source code; in this
## case, the definition occurs in the translation unit. In general, the
## lexical parent for a given entity can change without affecting the semantics
## of the program, and the lexical parent of different declarations of the
## same entity may be different. Changing the semantic parent of a declaration,
## on the other hand, can have a major impact on semantics, and redeclarations
## of a particular entity should all have the same semantic context.
## 
## In the example above, both declarations of C::f have C as their
## semantic context, while the lexical context of the first C::f is C
## and the lexical context of the second C::f is the translation unit.
## 
## For declarations written in the global scope, the lexical parent is
## the translation unit.
proc clang_getCursorLexicalParent*(cursor :CXCursor) :CXCursor {.importc:"clang_getCursorLexicalParent", cdecl, dynlib:libclang.}
## 
## Determine the set of methods that are overridden by the given
## method.
## 
## In both Objective-C and C++, a method (aka virtual member function,
## in C++) can override a virtual method in a base class. For
## Objective-C, a method is said to override any method in the class's
## base class, its protocols, or its categories' protocols, that has the same
## selector and is of the same kind (class or instance).
## If no such method exists, the search continues to the class's superclass,
## its protocols, and its categories, and so on. A method from an Objective-C
## implementation is considered to override the same methods as its
## corresponding method in the interface.
## 
## For C++, a virtual member function overrides any virtual member
## function with the same signature that occurs in its base
## classes. With multiple inheritance, a virtual member function can
## override several virtual member functions coming from different
## base classes.
## 
## In all cases, this function determines the immediate overridden
## method, rather than all of the overridden methods. For example, if
## a method is originally declared in a class A, then overridden in B
## (which in inherits from A) and also in C (which inherited from B),
## then the only overridden method returned from this function when
## invoked on C's method will be B's method. The client may then
## invoke this function again, given the previously-found overridden
## methods, to map out the complete method-override set.
## 
## \param cursor A cursor representing an Objective-C or C++
## method. This routine will compute the set of methods that this
## method overrides.
## 
## \param overridden A pointer whose pointee will be replaced with a
## pointer to an array of cursors, representing the set of overridden
## methods. If there are no overridden methods, the pointee will be
## set to NULL. The pointee must be freed via a call to
## clang_disposeOverriddenCursors().
## 
## \param num_overridden A pointer to the number of overridden
## functions, will be set to the number of overridden functions in the
## array pointed to by overridden.
proc clang_getOverriddenCursors*(cursor :CXCursor; overridden :ptr ptr CXCursor; num_overridden :ptr cuint) {.importc:"clang_getOverriddenCursors", cdecl, dynlib:libclang.}
## 
## Free the set of overridden cursors returned by \c
## clang_getOverriddenCursors().
proc clang_disposeOverriddenCursors*(overridden :ptr CXCursor) {.importc:"clang_disposeOverriddenCursors", cdecl, dynlib:libclang.}
## 
## Retrieve the file that is included by the given inclusion directive
## cursor.
proc clang_getIncludedFile*(cursor :CXCursor) :CXFile {.importc:"clang_getIncludedFile", cdecl, dynlib:libclang.}
## 
## Map a source location to the cursor that describes the entity at that
## location in the source code.
## 
## clang_getCursor() maps an arbitrary source location within a translation
## unit down to the most specific cursor that describes the entity at that
## location. For example, given an expression x + y, invoking
## clang_getCursor() with a source location pointing to "x" will return the
## cursor for "x"; similarly for "y". If the cursor points anywhere between
## "x" or "y" (e.g., on the + or the whitespace around it), clang_getCursor()
## will return a cursor referring to the "+" expression.
## 
## \returns a cursor representing the entity at the given source location, or
## a NULL cursor if no such entity can be found.
proc clang_getCursor*(a0 :CXTranslationUnit; a1 :CXSourceLocation) :CXCursor {.importc:"clang_getCursor", cdecl, dynlib:libclang.}
## 
## Retrieve the physical location of the source constructor referenced
## by the given cursor.
## 
## The location of a declaration is typically the location of the name of that
## declaration, where the name of that declaration would occur if it is
## unnamed, or some keyword that introduces that particular declaration.
## The location of a reference is where that reference occurs within the
## source code.
proc clang_getCursorLocation*(a0 :CXCursor) :CXSourceLocation {.importc:"clang_getCursorLocation", cdecl, dynlib:libclang.}
## 
## Retrieve the physical extent of the source construct referenced by
## the given cursor.
## 
## The extent of a cursor starts with the file/line/column pointing at the
## first character within the source construct that the cursor refers to and
## ends with the last character within that source construct. For a
## declaration, the extent covers the declaration itself. For a reference,
## the extent covers the location of the reference (e.g., where the referenced
## entity was actually used).
proc clang_getCursorExtent*(a0 :CXCursor) :CXSourceRange {.importc:"clang_getCursorExtent", cdecl, dynlib:libclang.}
## 
## Describes the kind of type
type enum_CXTypeKind* = cint
const
  CXType_Invalid* :enum_CXTypeKind= 0
  CXType_Unexposed* :enum_CXTypeKind= 1
  CXType_Void* :enum_CXTypeKind= 2
  CXType_Bool* :enum_CXTypeKind= 3
  CXType_Char_U* :enum_CXTypeKind= 4
  CXType_UChar* :enum_CXTypeKind= 5
  CXType_Char16* :enum_CXTypeKind= 6
  CXType_Char32* :enum_CXTypeKind= 7
  CXType_UShort* :enum_CXTypeKind= 8
  CXType_UInt* :enum_CXTypeKind= 9
  CXType_ULong* :enum_CXTypeKind= 10
  CXType_ULongLong* :enum_CXTypeKind= 11
  CXType_UInt128* :enum_CXTypeKind= 12
  CXType_Char_S* :enum_CXTypeKind= 13
  CXType_SChar* :enum_CXTypeKind= 14
  CXType_WChar* :enum_CXTypeKind= 15
  CXType_Short* :enum_CXTypeKind= 16
  CXType_Int* :enum_CXTypeKind= 17
  CXType_Long* :enum_CXTypeKind= 18
  CXType_LongLong* :enum_CXTypeKind= 19
  CXType_Int128* :enum_CXTypeKind= 20
  CXType_Float* :enum_CXTypeKind= 21
  CXType_Double* :enum_CXTypeKind= 22
  CXType_LongDouble* :enum_CXTypeKind= 23
  CXType_NullPtr* :enum_CXTypeKind= 24
  CXType_Overload* :enum_CXTypeKind= 25
  CXType_Dependent* :enum_CXTypeKind= 26
  CXType_ObjCId* :enum_CXTypeKind= 27
  CXType_ObjCClass* :enum_CXTypeKind= 28
  CXType_ObjCSel* :enum_CXTypeKind= 29
  CXType_Float128* :enum_CXTypeKind= 30
  CXType_Half* :enum_CXTypeKind= 31
  CXType_Float16* :enum_CXTypeKind= 32
  CXType_ShortAccum* :enum_CXTypeKind= 33
  CXType_Accum* :enum_CXTypeKind= 34
  CXType_LongAccum* :enum_CXTypeKind= 35
  CXType_UShortAccum* :enum_CXTypeKind= 36
  CXType_UAccum* :enum_CXTypeKind= 37
  CXType_ULongAccum* :enum_CXTypeKind= 38
  CXType_BFloat16* :enum_CXTypeKind= 39
  CXType_Ibm128* :enum_CXTypeKind= 40
  CXType_FirstBuiltin* :enum_CXTypeKind= 2
  CXType_LastBuiltin* :enum_CXTypeKind= 40
  CXType_Complex* :enum_CXTypeKind= 100
  CXType_Pointer* :enum_CXTypeKind= 101
  CXType_BlockPointer* :enum_CXTypeKind= 102
  CXType_LValueReference* :enum_CXTypeKind= 103
  CXType_RValueReference* :enum_CXTypeKind= 104
  CXType_Record* :enum_CXTypeKind= 105
  CXType_Enum* :enum_CXTypeKind= 106
  CXType_Typedef* :enum_CXTypeKind= 107
  CXType_ObjCInterface* :enum_CXTypeKind= 108
  CXType_ObjCObjectPointer* :enum_CXTypeKind= 109
  CXType_FunctionNoProto* :enum_CXTypeKind= 110
  CXType_FunctionProto* :enum_CXTypeKind= 111
  CXType_ConstantArray* :enum_CXTypeKind= 112
  CXType_Vector* :enum_CXTypeKind= 113
  CXType_IncompleteArray* :enum_CXTypeKind= 114
  CXType_VariableArray* :enum_CXTypeKind= 115
  CXType_DependentSizedArray* :enum_CXTypeKind= 116
  CXType_MemberPointer* :enum_CXTypeKind= 117
  CXType_Auto* :enum_CXTypeKind= 118
  CXType_Elaborated* :enum_CXTypeKind= 119
  CXType_Pipe* :enum_CXTypeKind= 120
  CXType_OCLImage1dRO* :enum_CXTypeKind= 121
  CXType_OCLImage1dArrayRO* :enum_CXTypeKind= 122
  CXType_OCLImage1dBufferRO* :enum_CXTypeKind= 123
  CXType_OCLImage2dRO* :enum_CXTypeKind= 124
  CXType_OCLImage2dArrayRO* :enum_CXTypeKind= 125
  CXType_OCLImage2dDepthRO* :enum_CXTypeKind= 126
  CXType_OCLImage2dArrayDepthRO* :enum_CXTypeKind= 127
  CXType_OCLImage2dMSAARO* :enum_CXTypeKind= 128
  CXType_OCLImage2dArrayMSAARO* :enum_CXTypeKind= 129
  CXType_OCLImage2dMSAADepthRO* :enum_CXTypeKind= 130
  CXType_OCLImage2dArrayMSAADepthRO* :enum_CXTypeKind= 131
  CXType_OCLImage3dRO* :enum_CXTypeKind= 132
  CXType_OCLImage1dWO* :enum_CXTypeKind= 133
  CXType_OCLImage1dArrayWO* :enum_CXTypeKind= 134
  CXType_OCLImage1dBufferWO* :enum_CXTypeKind= 135
  CXType_OCLImage2dWO* :enum_CXTypeKind= 136
  CXType_OCLImage2dArrayWO* :enum_CXTypeKind= 137
  CXType_OCLImage2dDepthWO* :enum_CXTypeKind= 138
  CXType_OCLImage2dArrayDepthWO* :enum_CXTypeKind= 139
  CXType_OCLImage2dMSAAWO* :enum_CXTypeKind= 140
  CXType_OCLImage2dArrayMSAAWO* :enum_CXTypeKind= 141
  CXType_OCLImage2dMSAADepthWO* :enum_CXTypeKind= 142
  CXType_OCLImage2dArrayMSAADepthWO* :enum_CXTypeKind= 143
  CXType_OCLImage3dWO* :enum_CXTypeKind= 144
  CXType_OCLImage1dRW* :enum_CXTypeKind= 145
  CXType_OCLImage1dArrayRW* :enum_CXTypeKind= 146
  CXType_OCLImage1dBufferRW* :enum_CXTypeKind= 147
  CXType_OCLImage2dRW* :enum_CXTypeKind= 148
  CXType_OCLImage2dArrayRW* :enum_CXTypeKind= 149
  CXType_OCLImage2dDepthRW* :enum_CXTypeKind= 150
  CXType_OCLImage2dArrayDepthRW* :enum_CXTypeKind= 151
  CXType_OCLImage2dMSAARW* :enum_CXTypeKind= 152
  CXType_OCLImage2dArrayMSAARW* :enum_CXTypeKind= 153
  CXType_OCLImage2dMSAADepthRW* :enum_CXTypeKind= 154
  CXType_OCLImage2dArrayMSAADepthRW* :enum_CXTypeKind= 155
  CXType_OCLImage3dRW* :enum_CXTypeKind= 156
  CXType_OCLSampler* :enum_CXTypeKind= 157
  CXType_OCLEvent* :enum_CXTypeKind= 158
  CXType_OCLQueue* :enum_CXTypeKind= 159
  CXType_OCLReserveID* :enum_CXTypeKind= 160
  CXType_ObjCObject* :enum_CXTypeKind= 161
  CXType_ObjCTypeParam* :enum_CXTypeKind= 162
  CXType_Attributed* :enum_CXTypeKind= 163
  CXType_OCLIntelSubgroupAVCMcePayload* :enum_CXTypeKind= 164
  CXType_OCLIntelSubgroupAVCImePayload* :enum_CXTypeKind= 165
  CXType_OCLIntelSubgroupAVCRefPayload* :enum_CXTypeKind= 166
  CXType_OCLIntelSubgroupAVCSicPayload* :enum_CXTypeKind= 167
  CXType_OCLIntelSubgroupAVCMceResult* :enum_CXTypeKind= 168
  CXType_OCLIntelSubgroupAVCImeResult* :enum_CXTypeKind= 169
  CXType_OCLIntelSubgroupAVCRefResult* :enum_CXTypeKind= 170
  CXType_OCLIntelSubgroupAVCSicResult* :enum_CXTypeKind= 171
  CXType_OCLIntelSubgroupAVCImeResultSingleReferenceStreamout* :enum_CXTypeKind= 172
  CXType_OCLIntelSubgroupAVCImeResultDualReferenceStreamout* :enum_CXTypeKind= 173
  CXType_OCLIntelSubgroupAVCImeSingleReferenceStreamin* :enum_CXTypeKind= 174
  CXType_OCLIntelSubgroupAVCImeDualReferenceStreamin* :enum_CXTypeKind= 175
  CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout* :enum_CXTypeKind= 172
  CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout* :enum_CXTypeKind= 173
  CXType_OCLIntelSubgroupAVCImeSingleRefStreamin* :enum_CXTypeKind= 174
  CXType_OCLIntelSubgroupAVCImeDualRefStreamin* :enum_CXTypeKind= 175
  CXType_ExtVector* :enum_CXTypeKind= 176
  CXType_Atomic* :enum_CXTypeKind= 177
  CXType_BTFTagAttributed* :enum_CXTypeKind= 178
type CXTypeKind* = enum_CXTypeKind
## 
## Describes the calling convention of a function type
type enum_CXCallingConv* = cint
const
  CXCallingConv_Default* :enum_CXCallingConv= 0
  CXCallingConv_C* :enum_CXCallingConv= 1
  CXCallingConv_X86StdCall* :enum_CXCallingConv= 2
  CXCallingConv_X86FastCall* :enum_CXCallingConv= 3
  CXCallingConv_X86ThisCall* :enum_CXCallingConv= 4
  CXCallingConv_X86Pascal* :enum_CXCallingConv= 5
  CXCallingConv_AAPCS* :enum_CXCallingConv= 6
  CXCallingConv_AAPCS_VFP* :enum_CXCallingConv= 7
  CXCallingConv_X86RegCall* :enum_CXCallingConv= 8
  CXCallingConv_IntelOclBicc* :enum_CXCallingConv= 9
  CXCallingConv_Win64* :enum_CXCallingConv= 10
  CXCallingConv_X86_64Win64* :enum_CXCallingConv= 10
  CXCallingConv_X86_64SysV* :enum_CXCallingConv= 11
  CXCallingConv_X86VectorCall* :enum_CXCallingConv= 12
  CXCallingConv_Swift* :enum_CXCallingConv= 13
  CXCallingConv_PreserveMost* :enum_CXCallingConv= 14
  CXCallingConv_PreserveAll* :enum_CXCallingConv= 15
  CXCallingConv_AArch64VectorCall* :enum_CXCallingConv= 16
  CXCallingConv_SwiftAsync* :enum_CXCallingConv= 17
  CXCallingConv_AArch64SVEPCS* :enum_CXCallingConv= 18
  CXCallingConv_M68kRTD* :enum_CXCallingConv= 19
  CXCallingConv_Invalid* :enum_CXCallingConv= 100
  CXCallingConv_Unexposed* :enum_CXCallingConv= 200
type CXCallingConv* = enum_CXCallingConv
## 
## The type of an element in the abstract syntax tree.
type lute r* {.eal on.} = object
  rtua* :l file pat
  h to* :array[o,  an abs]
## 
## Retrieve the type of a CXCursor (if any).
proc clang_getCursorType*(C :CXCursor) :CXType {.importc:"clang_getCursorType", cdecl, dynlib:libclang.}
## 
## Pretty-print the underlying type using the rules of the
## language of the translation unit from which it came.
## 
## If the type is invalid, an empty string is returned.
proc clang_getTypeSpelling*(CT :CXType) :CXString {.importc:"clang_getTypeSpelling", cdecl, dynlib:libclang.}
## 
## Retrieve the underlying type of a typedef declaration.
## 
## If the cursor does not reference a typedef declaration, an invalid type is
## returned.
proc clang_getTypedefDeclUnderlyingType*(C :CXCursor) :CXType {.importc:"clang_getTypedefDeclUnderlyingType", cdecl, dynlib:libclang.}
## 
## Retrieve the integer type of an enum declaration.
## 
## If the cursor does not reference an enum declaration, an invalid type is
## returned.
proc clang_getEnumDeclIntegerType*(C :CXCursor) :CXType {.importc:"clang_getEnumDeclIntegerType", cdecl, dynlib:libclang.}
## 
## Retrieve the integer value of an enum constant declaration as a signed
##  long long.
## 
## If the cursor does not reference an enum constant declaration, LLONG_MIN is
## returned. Since this is also potentially a valid constant value, the kind of
## the cursor must be verified before calling this function.
proc clang_getEnumConstantDeclValue*(C :CXCursor) :clonglong {.importc:"clang_getEnumConstantDeclValue", cdecl, dynlib:libclang.}
## 
## Retrieve the integer value of an enum constant declaration as an unsigned
##  long long.
## 
## If the cursor does not reference an enum constant declaration, ULLONG_MAX is
## returned. Since this is also potentially a valid constant value, the kind of
## the cursor must be verified before calling this function.
proc clang_getEnumConstantDeclUnsignedValue*(C :CXCursor) :culonglong {.importc:"clang_getEnumConstantDeclUnsignedValue", cdecl, dynlib:libclang.}
## 
## Returns non-zero if the cursor specifies a Record member that is a bit-field.
proc clang_Cursor_isBitField*(C :CXCursor) :cuint {.importc:"clang_Cursor_isBitField", cdecl, dynlib:libclang.}
## 
## Retrieve the bit width of a bit-field declaration as an integer.
## 
## If the cursor does not reference a bit-field, or if the bit-field's width
## expression cannot be evaluated, -1 is returned.
## 
## For example:
## \code
## if (clang_Cursor_isBitField(Cursor)) {
##   int Width = clang_getFieldDeclBitWidth(Cursor);
##   if (Width != -1) {
##     // The bit-field width is not value-dependent.
##   }
## }
## \endcode
proc clang_getFieldDeclBitWidth*(C :CXCursor) :cint {.importc:"clang_getFieldDeclBitWidth", cdecl, dynlib:libclang.}
## 
## Retrieve the number of non-variadic arguments associated with a given
## cursor.
## 
## The number of arguments can be determined for calls as well as for
## declarations of functions or methods. For other cursors -1 is returned.
proc clang_Cursor_getNumArguments*(C :CXCursor) :cint {.importc:"clang_Cursor_getNumArguments", cdecl, dynlib:libclang.}
## 
## Retrieve the argument cursor of a function or method.
## 
## The argument cursor can be determined for calls as well as for declarations
## of functions or methods. For other cursors and for invalid indices, an
## invalid cursor is returned.
proc clang_Cursor_getArgument*(C :CXCursor; i :cuint) :CXCursor {.importc:"clang_Cursor_getArgument", cdecl, dynlib:libclang.}
## 
## Describes the kind of a template argument.
## 
## See the definition of llvm::clang::TemplateArgument::ArgKind for full
## element descriptions.
type enum_CXTemplateArgumentKind* = cint
const
  CXTemplateArgumentKind_Null* :enum_CXTemplateArgumentKind= 0
  CXTemplateArgumentKind_Type* :enum_CXTemplateArgumentKind= 1
  CXTemplateArgumentKind_Declaration* :enum_CXTemplateArgumentKind= 2
  CXTemplateArgumentKind_NullPtr* :enum_CXTemplateArgumentKind= 3
  CXTemplateArgumentKind_Integral* :enum_CXTemplateArgumentKind= 4
  CXTemplateArgumentKind_Template* :enum_CXTemplateArgumentKind= 5
  CXTemplateArgumentKind_TemplateExpansion* :enum_CXTemplateArgumentKind= 6
  CXTemplateArgumentKind_Expression* :enum_CXTemplateArgumentKind= 7
  CXTemplateArgumentKind_Pack* :enum_CXTemplateArgumentKind= 8
  CXTemplateArgumentKind_Invalid* :enum_CXTemplateArgumentKind= 9
type CXTemplateArgumentKind* = enum_CXTemplateArgumentKind
## 
## Returns the number of template args of a function, struct, or class decl
## representing a template specialization.
## 
## If the argument cursor cannot be converted into a template function
## declaration, -1 is returned.
## 
## For example, for the following declaration and specialization:
##   template <typename T, int kInt, bool kBool>
##   void foo() { ... }
## 
##   template <>
##   void foo<float, -7, true>();
## 
## The value 3 would be returned from this call.
proc clang_Cursor_getNumTemplateArguments*(C :CXCursor) :cint {.importc:"clang_Cursor_getNumTemplateArguments", cdecl, dynlib:libclang.}
## 
## Retrieve the kind of the I'th template argument of the CXCursor C.
## 
## If the argument CXCursor does not represent a FunctionDecl, StructDecl, or
## ClassTemplatePartialSpecialization, an invalid template argument kind is
## returned.
## 
## For example, for the following declaration and specialization:
##   template <typename T, int kInt, bool kBool>
##   void foo() { ... }
## 
##   template <>
##   void foo<float, -7, true>();
## 
## For I = 0, 1, and 2, Type, Integral, and Integral will be returned,
## respectively.
proc clang_Cursor_getTemplateArgumentKind*(C :CXCursor; I :cuint) :CXTemplateArgumentKind {.importc:"clang_Cursor_getTemplateArgumentKind", cdecl, dynlib:libclang.}
## 
## Retrieve a CXType representing the type of a TemplateArgument of a
##  function decl representing a template specialization.
## 
## If the argument CXCursor does not represent a FunctionDecl, StructDecl,
## ClassDecl or ClassTemplatePartialSpecialization whose I'th template argument
## has a kind of CXTemplateArgKind_Integral, an invalid type is returned.
## 
## For example, for the following declaration and specialization:
##   template <typename T, int kInt, bool kBool>
##   void foo() { ... }
## 
##   template <>
##   void foo<float, -7, true>();
## 
## If called with I = 0, "float", will be returned.
## Invalid types will be returned for I == 1 or 2.
proc clang_Cursor_getTemplateArgumentType*(C :CXCursor; I :cuint) :CXType {.importc:"clang_Cursor_getTemplateArgumentType", cdecl, dynlib:libclang.}
## 
## Retrieve the value of an Integral TemplateArgument (of a function
##  decl representing a template specialization) as a signed long long.
## 
## It is undefined to call this function on a CXCursor that does not represent a
## FunctionDecl, StructDecl, ClassDecl or ClassTemplatePartialSpecialization
## whose I'th template argument is not an integral value.
## 
## For example, for the following declaration and specialization:
##   template <typename T, int kInt, bool kBool>
##   void foo() { ... }
## 
##   template <>
##   void foo<float, -7, true>();
## 
## If called with I = 1 or 2, -7 or true will be returned, respectively.
## For I == 0, this function's behavior is undefined.
proc clang_Cursor_getTemplateArgumentValue*(C :CXCursor; I :cuint) :clonglong {.importc:"clang_Cursor_getTemplateArgumentValue", cdecl, dynlib:libclang.}
## 
## Retrieve the value of an Integral TemplateArgument (of a function
##  decl representing a template specialization) as an unsigned long long.
## 
## It is undefined to call this function on a CXCursor that does not represent a
## FunctionDecl, StructDecl, ClassDecl or ClassTemplatePartialSpecialization or
## whose I'th template argument is not an integral value.
## 
## For example, for the following declaration and specialization:
##   template <typename T, int kInt, bool kBool>
##   void foo() { ... }
## 
##   template <>
##   void foo<float, 2147483649, true>();
## 
## If called with I = 1 or 2, 2147483649 or true will be returned, respectively.
## For I == 0, this function's behavior is undefined.
proc clang_Cursor_getTemplateArgumentUnsignedValue*(C :CXCursor; I :cuint) :culonglong {.importc:"clang_Cursor_getTemplateArgumentUnsignedValue", cdecl, dynlib:libclang.}
## 
## Determine whether two CXTypes represent the same type.
## 
## \returns non-zero if the CXTypes represent the same type and
##          zero otherwise.
proc clang_equalTypes*(A :CXType; B :CXType) :cuint {.importc:"clang_equalTypes", cdecl, dynlib:libclang.}
## 
## Return the canonical type for a CXType.
## 
## Clang's type system explicitly models typedefs and all the ways
## a specific type can be represented.  The canonical type is the underlying
## type with all the "sugar" removed.  For example, if 'T' is a typedef
## for 'int', the canonical type for 'T' would be 'int'.
proc clang_getCanonicalType*(T :CXType) :CXType {.importc:"clang_getCanonicalType", cdecl, dynlib:libclang.}
## 
## Determine whether a CXType has the "const" qualifier set,
## without looking through typedefs that may have added "const" at a
## different level.
proc clang_isConstQualifiedType*(T :CXType) :cuint {.importc:"clang_isConstQualifiedType", cdecl, dynlib:libclang.}
## 
## Determine whether a  CXCursor that is a macro, is
## function like.
proc clang_Cursor_isMacroFunctionLike*(C :CXCursor) :cuint {.importc:"clang_Cursor_isMacroFunctionLike", cdecl, dynlib:libclang.}
## 
## Determine whether a  CXCursor that is a macro, is a
## builtin one.
proc clang_Cursor_isMacroBuiltin*(C :CXCursor) :cuint {.importc:"clang_Cursor_isMacroBuiltin", cdecl, dynlib:libclang.}
## 
## Determine whether a  CXCursor that is a function declaration, is an
## inline declaration.
proc clang_Cursor_isFunctionInlined*(C :CXCursor) :cuint {.importc:"clang_Cursor_isFunctionInlined", cdecl, dynlib:libclang.}
## 
## Determine whether a CXType has the "volatile" qualifier set,
## without looking through typedefs that may have added "volatile" at
## a different level.
proc clang_isVolatileQualifiedType*(T :CXType) :cuint {.importc:"clang_isVolatileQualifiedType", cdecl, dynlib:libclang.}
## 
## Determine whether a CXType has the "restrict" qualifier set,
## without looking through typedefs that may have added "restrict" at a
## different level.
proc clang_isRestrictQualifiedType*(T :CXType) :cuint {.importc:"clang_isRestrictQualifiedType", cdecl, dynlib:libclang.}
## 
## Returns the address space of the given type.
proc clang_getAddressSpace*(T :CXType) :cuint {.importc:"clang_getAddressSpace", cdecl, dynlib:libclang.}
## 
## Returns the typedef name of the given type.
proc clang_getTypedefName*(CT :CXType) :CXString {.importc:"clang_getTypedefName", cdecl, dynlib:libclang.}
## 
## For pointer types, returns the type of the pointee.
proc clang_getPointeeType*(T :CXType) :CXType {.importc:"clang_getPointeeType", cdecl, dynlib:libclang.}
## 
## Retrieve the unqualified variant of the given type, removing as
## little sugar as possible.
## 
## For example, given the following series of typedefs:
## 
## \code
## typedef int Integer;
## typedef const Integer CInteger;
## typedef CInteger DifferenceType;
## \endcode
## 
## Executing clang_getUnqualifiedType() on a CXType that
## represents DifferenceType, will desugar to a type representing
## Integer, that has no qualifiers.
## 
## And, executing clang_getUnqualifiedType() on the type of the
## first argument of the following function declaration:
## 
## \code
## void foo(const int);
## \endcode
## 
## Will return a type representing int, removing the const
## qualifier.
## 
## Sugar over array types is not desugared.
## 
## A type can be checked for qualifiers with \c
## clang_isConstQualifiedType(), clang_isVolatileQualifiedType()
## and clang_isRestrictQualifiedType().
## 
## A type that resulted from a call to clang_getUnqualifiedType
## will return false for all of the above calls.
proc clang_getUnqualifiedType*(CT :CXType) :CXType {.importc:"clang_getUnqualifiedType", cdecl, dynlib:libclang.}
## 
## For reference types (e.g., "const int&"), returns the type that the
## reference refers to (e.g "const int").
## 
## Otherwise, returns the type itself.
## 
## A type that has kind CXType_LValueReference or
## CXType_RValueReference is a reference type.
proc clang_getNonReferenceType*(CT :CXType) :CXType {.importc:"clang_getNonReferenceType", cdecl, dynlib:libclang.}
## 
## Return the cursor for the declaration of the given type.
proc clang_getTypeDeclaration*(T :CXType) :CXCursor {.importc:"clang_getTypeDeclaration", cdecl, dynlib:libclang.}
## 
## Returns the Objective-C type encoding for the specified declaration.
proc clang_getDeclObjCTypeEncoding*(C :CXCursor) :CXString {.importc:"clang_getDeclObjCTypeEncoding", cdecl, dynlib:libclang.}
## 
## Returns the Objective-C type encoding for the specified CXType.
proc clang_Type_getObjCEncoding*(`type` :CXType) :CXString {.importc:"clang_Type_getObjCEncoding", cdecl, dynlib:libclang.}
## 
## Retrieve the spelling of a given CXTypeKind.
proc clang_getTypeKindSpelling*(K :CXTypeKind) :CXString {.importc:"clang_getTypeKindSpelling", cdecl, dynlib:libclang.}
## 
## Retrieve the calling convention associated with a function type.
## 
## If a non-function type is passed in, CXCallingConv_Invalid is returned.
proc clang_getFunctionTypeCallingConv*(T :CXType) :CXCallingConv {.importc:"clang_getFunctionTypeCallingConv", cdecl, dynlib:libclang.}
## 
## Retrieve the return type associated with a function type.
## 
## If a non-function type is passed in, an invalid type is returned.
proc clang_getResultType*(T :CXType) :CXType {.importc:"clang_getResultType", cdecl, dynlib:libclang.}
## 
## Retrieve the exception specification type associated with a function type.
## This is a value of type CXCursor_ExceptionSpecificationKind.
## 
## If a non-function type is passed in, an error code of -1 is returned.
proc clang_getExceptionSpecificationType*(T :CXType) :cint {.importc:"clang_getExceptionSpecificationType", cdecl, dynlib:libclang.}
## 
## Retrieve the number of non-variadic parameters associated with a
## function type.
## 
## If a non-function type is passed in, -1 is returned.
proc clang_getNumArgTypes*(T :CXType) :cint {.importc:"clang_getNumArgTypes", cdecl, dynlib:libclang.}
## 
## Retrieve the type of a parameter of a function type.
## 
## If a non-function type is passed in or the function does not have enough
## parameters, an invalid type is returned.
proc clang_getArgType*(T :CXType; i :cuint) :CXType {.importc:"clang_getArgType", cdecl, dynlib:libclang.}
## 
## Retrieves the base type of the ObjCObjectType.
## 
## If the type is not an ObjC object, an invalid type is returned.
proc clang_Type_getObjCObjectBaseType*(T :CXType) :CXType {.importc:"clang_Type_getObjCObjectBaseType", cdecl, dynlib:libclang.}
## 
## Retrieve the number of protocol references associated with an ObjC object/id.
## 
## If the type is not an ObjC object, 0 is returned.
proc clang_Type_getNumObjCProtocolRefs*(T :CXType) :cuint {.importc:"clang_Type_getNumObjCProtocolRefs", cdecl, dynlib:libclang.}
## 
## Retrieve the decl for a protocol reference for an ObjC object/id.
## 
## If the type is not an ObjC object or there are not enough protocol
## references, an invalid cursor is returned.
proc clang_Type_getObjCProtocolDecl*(T :CXType; i :cuint) :CXCursor {.importc:"clang_Type_getObjCProtocolDecl", cdecl, dynlib:libclang.}
## 
## Retrieve the number of type arguments associated with an ObjC object.
## 
## If the type is not an ObjC object, 0 is returned.
proc clang_Type_getNumObjCTypeArgs*(T :CXType) :cuint {.importc:"clang_Type_getNumObjCTypeArgs", cdecl, dynlib:libclang.}
## 
## Retrieve a type argument associated with an ObjC object.
## 
## If the type is not an ObjC or the index is not valid,
## an invalid type is returned.
proc clang_Type_getObjCTypeArg*(T :CXType; i :cuint) :CXType {.importc:"clang_Type_getObjCTypeArg", cdecl, dynlib:libclang.}
## 
## Return 1 if the CXType is a variadic function type, and 0 otherwise.
proc clang_isFunctionTypeVariadic*(T :CXType) :cuint {.importc:"clang_isFunctionTypeVariadic", cdecl, dynlib:libclang.}
## 
## Retrieve the return type associated with a given cursor.
## 
## This only returns a valid type if the cursor refers to a function or method.
proc clang_getCursorResultType*(C :CXCursor) :CXType {.importc:"clang_getCursorResultType", cdecl, dynlib:libclang.}
## 
## Retrieve the exception specification type associated with a given cursor.
## This is a value of type CXCursor_ExceptionSpecificationKind.
## 
## This only returns a valid result if the cursor refers to a function or
## method.
proc clang_getCursorExceptionSpecificationType*(C :CXCursor) :cint {.importc:"clang_getCursorExceptionSpecificationType", cdecl, dynlib:libclang.}
## 
## Return 1 if the CXType is a POD (plain old data) type, and 0
##  otherwise.
proc clang_isPODType*(T :CXType) :cuint {.importc:"clang_isPODType", cdecl, dynlib:libclang.}
## 
## Return the element type of an array, complex, or vector type.
## 
## If a type is passed in that is not an array, complex, or vector type,
## an invalid type is returned.
proc clang_getElementType*(T :CXType) :CXType {.importc:"clang_getElementType", cdecl, dynlib:libclang.}
## 
## Return the number of elements of an array or vector type.
## 
## If a type is passed in that is not an array or vector type,
## -1 is returned.
proc clang_getNumElements*(T :CXType) :clonglong {.importc:"clang_getNumElements", cdecl, dynlib:libclang.}
## 
## Return the element type of an array type.
## 
## If a non-array type is passed in, an invalid type is returned.
proc clang_getArrayElementType*(T :CXType) :CXType {.importc:"clang_getArrayElementType", cdecl, dynlib:libclang.}
## 
## Return the array size of a constant array.
## 
## If a non-array type is passed in, -1 is returned.
proc clang_getArraySize*(T :CXType) :clonglong {.importc:"clang_getArraySize", cdecl, dynlib:libclang.}
## 
## Retrieve the type named by the qualified-id.
## 
## If a non-elaborated type is passed in, an invalid type is returned.
proc clang_Type_getNamedType*(T :CXType) :CXType {.importc:"clang_Type_getNamedType", cdecl, dynlib:libclang.}
## 
## Determine if a typedef is 'transparent' tag.
## 
## A typedef is considered 'transparent' if it shares a name and spelling
## location with its underlying tag type, as is the case with the NS_ENUM macro.
## 
## \returns non-zero if transparent and zero otherwise.
proc clang_Type_isTransparentTagTypedef*(T :CXType) :cuint {.importc:"clang_Type_isTransparentTagTypedef", cdecl, dynlib:libclang.}
type enum_CXTypeNullabilityKind* = cint
const
  CXTypeNullability_NonNull* :enum_CXTypeNullabilityKind= 0
  CXTypeNullability_Nullable* :enum_CXTypeNullabilityKind= 1
  CXTypeNullability_Unspecified* :enum_CXTypeNullabilityKind= 2
  CXTypeNullability_Invalid* :enum_CXTypeNullabilityKind= 3
  CXTypeNullability_NullableResult* :enum_CXTypeNullabilityKind= 4
type CXTypeNullabilityKind* = enum_CXTypeNullabilityKind
## 
## Retrieve the nullability kind of a pointer type.
proc clang_Type_getNullability*(T :CXType) :CXTypeNullabilityKind {.importc:"clang_Type_getNullability", cdecl, dynlib:libclang.}
## 
## List the possible error codes for clang_Type_getSizeOf,
##   clang_Type_getAlignOf, clang_Type_getOffsetOf and
##   clang_Cursor_getOffsetOf.
## 
## A value of this enumeration type can be returned if the target type is not
## a valid argument to sizeof, alignof or offsetof.
type enum_CXTypeLayoutError* = cint
const
  CXTypeLayoutError_Invalid* :enum_CXTypeLayoutError= -1
  CXTypeLayoutError_Incomplete* :enum_CXTypeLayoutError= -2
  CXTypeLayoutError_Dependent* :enum_CXTypeLayoutError= -3
  CXTypeLayoutError_NotConstantSize* :enum_CXTypeLayoutError= -4
  CXTypeLayoutError_InvalidFieldName* :enum_CXTypeLayoutError= -5
  CXTypeLayoutError_Undeduced* :enum_CXTypeLayoutError= -6
type CXTypeLayoutError* = enum_CXTypeLayoutError
## 
## Return the alignment of a type in bytes as per C++[expr.alignof]
##   standard.
## 
## If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
## If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
##   is returned.
## If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
##   returned.
## If the type declaration is not a constant size type,
##   CXTypeLayoutError_NotConstantSize is returned.
proc clang_Type_getAlignOf*(T :CXType) :clonglong {.importc:"clang_Type_getAlignOf", cdecl, dynlib:libclang.}
## 
## Return the class type of an member pointer type.
## 
## If a non-member-pointer type is passed in, an invalid type is returned.
proc clang_Type_getClassType*(T :CXType) :CXType {.importc:"clang_Type_getClassType", cdecl, dynlib:libclang.}
## 
## Return the size of a type in bytes as per C++[expr.sizeof] standard.
## 
## If the type declaration is invalid, CXTypeLayoutError_Invalid is returned.
## If the type declaration is an incomplete type, CXTypeLayoutError_Incomplete
##   is returned.
## If the type declaration is a dependent type, CXTypeLayoutError_Dependent is
##   returned.
proc clang_Type_getSizeOf*(T :CXType) :clonglong {.importc:"clang_Type_getSizeOf", cdecl, dynlib:libclang.}
## 
## Return the offset of a field named S in a record of type T in bits
##   as it would be returned by __offsetof__ as per C++11[18.2p4]
## 
## If the cursor is not a record field declaration, CXTypeLayoutError_Invalid
##   is returned.
## If the field's type declaration is an incomplete type,
##   CXTypeLayoutError_Incomplete is returned.
## If the field's type declaration is a dependent type,
##   CXTypeLayoutError_Dependent is returned.
## If the field's name S is not found,
##   CXTypeLayoutError_InvalidFieldName is returned.
proc clang_Type_getOffsetOf*(T :CXType; S :cstring) :clonglong {.importc:"clang_Type_getOffsetOf", cdecl, dynlib:libclang.}
## 
## Return the type that was modified by this attributed type.
## 
## If the type is not an attributed type, an invalid type is returned.
proc clang_Type_getModifiedType*(T :CXType) :CXType {.importc:"clang_Type_getModifiedType", cdecl, dynlib:libclang.}
## 
## Gets the type contained by this atomic type.
## 
## If a non-atomic type is passed in, an invalid type is returned.
proc clang_Type_getValueType*(CT :CXType) :CXType {.importc:"clang_Type_getValueType", cdecl, dynlib:libclang.}
## 
## Return the offset of the field represented by the Cursor.
## 
## If the cursor is not a field declaration, -1 is returned.
## If the cursor semantic parent is not a record field declaration,
##   CXTypeLayoutError_Invalid is returned.
## If the field's type declaration is an incomplete type,
##   CXTypeLayoutError_Incomplete is returned.
## If the field's type declaration is a dependent type,
##   CXTypeLayoutError_Dependent is returned.
## If the field's name S is not found,
##   CXTypeLayoutError_InvalidFieldName is returned.
proc clang_Cursor_getOffsetOfField*(C :CXCursor) :clonglong {.importc:"clang_Cursor_getOffsetOfField", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor represents an anonymous
## tag or namespace
proc clang_Cursor_isAnonymous*(C :CXCursor) :cuint {.importc:"clang_Cursor_isAnonymous", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor represents an anonymous record
## declaration.
proc clang_Cursor_isAnonymousRecordDecl*(C :CXCursor) :cuint {.importc:"clang_Cursor_isAnonymousRecordDecl", cdecl, dynlib:libclang.}
## 
## Determine whether the given cursor represents an inline namespace
## declaration.
proc clang_Cursor_isInlineNamespace*(C :CXCursor) :cuint {.importc:"clang_Cursor_isInlineNamespace", cdecl, dynlib:libclang.}
type enum_CXRefQualifierKind* = cint
const
  CXRefQualifier_None* :enum_CXRefQualifierKind= 0
  CXRefQualifier_LValue* :enum_CXRefQualifierKind= 1
  CXRefQualifier_RValue* :enum_CXRefQualifierKind= 2
type CXRefQualifierKind* = enum_CXRefQualifierKind
## 
## Returns the number of template arguments for given template
## specialization, or -1 if type T is not a template specialization.
proc clang_Type_getNumTemplateArguments*(T :CXType) :cint {.importc:"clang_Type_getNumTemplateArguments", cdecl, dynlib:libclang.}
## 
## Returns the type template argument of a template class specialization
## at given index.
## 
## This function only returns template type arguments and does not handle
## template template arguments or variadic packs.
proc clang_Type_getTemplateArgumentAsType*(T :CXType; i :cuint) :CXType {.importc:"clang_Type_getTemplateArgumentAsType", cdecl, dynlib:libclang.}
## 
## Retrieve the ref-qualifier kind of a function or method.
## 
## The ref-qualifier is returned for C++ functions or methods. For other types
## or non-C++ declarations, CXRefQualifier_None is returned.
proc clang_Type_getCXXRefQualifier*(T :CXType) :CXRefQualifierKind {.importc:"clang_Type_getCXXRefQualifier", cdecl, dynlib:libclang.}
## 
## Returns 1 if the base class specified by the cursor with kind
##   CX_CXXBaseSpecifier is virtual.
proc clang_isVirtualBase*(a0 :CXCursor) :cuint {.importc:"clang_isVirtualBase", cdecl, dynlib:libclang.}
## 
## Represents the C++ access control level to a base class for a
## cursor with kind CX_CXXBaseSpecifier.
type enum_CX_CXXAccessSpecifier* = cint
const
  CX_CXXInvalidAccessSpecifier* :enum_CX_CXXAccessSpecifier= 0
  CX_CXXPublic* :enum_CX_CXXAccessSpecifier= 1
  CX_CXXProtected* :enum_CX_CXXAccessSpecifier= 2
  CX_CXXPrivate* :enum_CX_CXXAccessSpecifier= 3
type CX_CXXAccessSpecifier* = enum_CX_CXXAccessSpecifier
## 
## Returns the access control level for the referenced object.
## 
## If the cursor refers to a C++ declaration, its access control level within
## its parent scope is returned. Otherwise, if the cursor refers to a base
## specifier or access specifier, the specifier itself is returned.
proc clang_getCXXAccessSpecifier*(a0 :CXCursor) :CX_CXXAccessSpecifier {.importc:"clang_getCXXAccessSpecifier", cdecl, dynlib:libclang.}
## 
## Represents the storage classes as declared in the source. CX_SC_Invalid
## was added for the case that the passed cursor in not a declaration.
type enum_CX_StorageClass* = cint
const
  CX_SC_Invalid* :enum_CX_StorageClass= 0
  CX_SC_None* :enum_CX_StorageClass= 1
  CX_SC_Extern* :enum_CX_StorageClass= 2
  CX_SC_Static* :enum_CX_StorageClass= 3
  CX_SC_PrivateExtern* :enum_CX_StorageClass= 4
  CX_SC_OpenCLWorkGroupLocal* :enum_CX_StorageClass= 5
  CX_SC_Auto* :enum_CX_StorageClass= 6
  CX_SC_Register* :enum_CX_StorageClass= 7
type CX_StorageClass* = enum_CX_StorageClass
## 
## Returns the storage class for a function or variable declaration.
## 
## If the passed in Cursor is not a function or variable declaration,
## CX_SC_Invalid is returned else the storage class.
proc clang_Cursor_getStorageClass*(a0 :CXCursor) :CX_StorageClass {.importc:"clang_Cursor_getStorageClass", cdecl, dynlib:libclang.}
## 
## Determine the number of overloaded declarations referenced by a
## CXCursor_OverloadedDeclRef cursor.
## 
## \param cursor The cursor whose overloaded declarations are being queried.
## 
## \returns The number of overloaded declarations referenced by cursor. If it
## is not a CXCursor_OverloadedDeclRef cursor, returns 0.
proc clang_getNumOverloadedDecls*(cursor :CXCursor) :cuint {.importc:"clang_getNumOverloadedDecls", cdecl, dynlib:libclang.}
## 
## Retrieve a cursor for one of the overloaded declarations referenced
## by a CXCursor_OverloadedDeclRef cursor.
## 
## \param cursor The cursor whose overloaded declarations are being queried.
## 
## \param index The zero-based index into the set of overloaded declarations in
## the cursor.
## 
## \returns A cursor representing the declaration referenced by the given
## cursor at the specified index. If the cursor does not have an
## associated set of overloaded declarations, or if the index is out of bounds,
## returns clang_getNullCursor();
proc clang_getOverloadedDecl*(cursor :CXCursor; index :cuint) :CXCursor {.importc:"clang_getOverloadedDecl", cdecl, dynlib:libclang.}
## 
## For cursors representing an iboutletcollection attribute,
##  this function returns the collection element type.
proc clang_getIBOutletCollectionType*(a0 :CXCursor) :CXType {.importc:"clang_getIBOutletCollectionType", cdecl, dynlib:libclang.}
## 
## Describes how the traversal of the children of a particular
## cursor should proceed after visiting a particular child cursor.
## 
## A value of this enumeration type should be returned by each
## CXCursorVisitor to indicate how clang_visitChildren() proceed.
type enum_CXChildVisitResult* = cint
const
  CXChildVisit_Break* :enum_CXChildVisitResult= 0
  CXChildVisit_Continue* :enum_CXChildVisitResult= 1
  CXChildVisit_Recurse* :enum_CXChildVisitResult= 2
type CXChildVisitResult* = enum_CXChildVisitResult
## 
## Visitor invoked for each cursor found by a traversal.
## 
## This visitor function will be invoked for each cursor found by
## clang_visitCursorChildren(). Its first argument is the cursor being
## visited, its second argument is the parent visitor for that cursor,
## and its third argument is the client data provided to
## clang_visitCursorChildren().
## 
## The visitor should return one of the CXChildVisitResult values
## to direct clang_visitCursorChildren().
type CXCursorVisitor* = proc (a0 :CXCursor; a1 :CXCursor; a2 :CXClientData) :CXChildVisitResult {.cdecl.}
## 
## Visit the children of a particular cursor.
## 
## This function visits all the direct children of the given cursor,
## invoking the given visitor function with the cursors of each
## visited child. The traversal may be recursive, if the visitor returns
## CXChildVisit_Recurse. The traversal may also be ended prematurely, if
## the visitor returns CXChildVisit_Break.
## 
## \param parent the cursor whose child may be visited. All kinds of
## cursors can be visited, including invalid cursors (which, by
## definition, have no children).
## 
## \param visitor the visitor function that will be invoked for each
## child of parent.
## 
## \param client_data pointer data supplied by the client, which will
## be passed to the visitor each time it is invoked.
## 
## \returns a non-zero value if the traversal was terminated
## prematurely by the visitor returning CXChildVisit_Break.
proc clang_visitChildren*(parent :CXCursor; visitor :CXCursorVisitor; client_data :CXClientData) :cuint {.importc:"clang_visitChildren", cdecl, dynlib:libclang.}
type
  struct_CXChildVisitResult* {.incompleteStruct.} = object
  priv_CXChildVisitResult* = struct_CXChildVisitResult
  CXCursorVisitorBlock* = ptr struct_CXChildVisitResult
## 
## Visits the children of a cursor using the specified block.  Behaves
## identically to clang_visitChildren() in all other respects.
proc clang_visitChildrenWithBlock*(parent :CXCursor; `block` :CXCursorVisitorBlock) :cuint {.importc:"clang_visitChildrenWithBlock", cdecl, dynlib:libclang.}
## 
## Retrieve a Unified Symbol Resolution (USR) for the entity referenced
## by the given cursor.
## 
## A Unified Symbol Resolution (USR) is a string that identifies a particular
## entity (function, class, variable, etc.) within a program. USRs can be
## compared across translation units to determine, e.g., when references in
## one translation refer to an entity defined in another translation unit.
proc clang_getCursorUSR*(a0 :CXCursor) :CXString {.importc:"clang_getCursorUSR", cdecl, dynlib:libclang.}
## 
## Construct a USR for a specified Objective-C class.
proc clang_constructUSR_ObjCClass*(class_name :cstring) :CXString {.importc:"clang_constructUSR_ObjCClass", cdecl, dynlib:libclang.}
## 
## Construct a USR for a specified Objective-C category.
proc clang_constructUSR_ObjCCategory*(class_name :cstring; category_name :cstring) :CXString {.importc:"clang_constructUSR_ObjCCategory", cdecl, dynlib:libclang.}
## 
## Construct a USR for a specified Objective-C protocol.
proc clang_constructUSR_ObjCProtocol*(protocol_name :cstring) :CXString {.importc:"clang_constructUSR_ObjCProtocol", cdecl, dynlib:libclang.}
## 
## Construct a USR for a specified Objective-C instance variable and
##   the USR for its containing class.
proc clang_constructUSR_ObjCIvar*(name :cstring; classUSR :CXString) :CXString {.importc:"clang_constructUSR_ObjCIvar", cdecl, dynlib:libclang.}
## 
## Construct a USR for a specified Objective-C method and
##   the USR for its containing class.
proc clang_constructUSR_ObjCMethod*(name :cstring; isInstanceMethod :cuint; classUSR :CXString) :CXString {.importc:"clang_constructUSR_ObjCMethod", cdecl, dynlib:libclang.}
## 
## Construct a USR for a specified Objective-C property and the USR
##  for its containing class.
proc clang_constructUSR_ObjCProperty*(property :cstring; classUSR :CXString) :CXString {.importc:"clang_constructUSR_ObjCProperty", cdecl, dynlib:libclang.}
## 
## Retrieve a name for the entity referenced by this cursor.
proc clang_getCursorSpelling*(a0 :CXCursor) :CXString {.importc:"clang_getCursorSpelling", cdecl, dynlib:libclang.}
## 
## Retrieve a range for a piece that forms the cursors spelling name.
## Most of the times there is only one range for the complete spelling but for
## Objective-C methods and Objective-C message expressions, there are multiple
## pieces for each selector identifier.
## 
## \param pieceIndex the index of the spelling name piece. If this is greater
## than the actual number of pieces, it will return a NULL (invalid) range.
## 
## \param options Reserved.
proc clang_Cursor_getSpellingNameRange*(a0 :CXCursor; pieceIndex :cuint; options :cuint) :CXSourceRange {.importc:"clang_Cursor_getSpellingNameRange", cdecl, dynlib:libclang.}
## 
## Opaque pointer representing a policy that controls pretty printing
## for clang_getCursorPrettyPrinted.
type CXPrintingPolicy* = pointer
## 
## Properties for the printing policy.
## 
## See clang::PrintingPolicy for more information.
type enum_CXPrintingPolicyProperty* = cint
const
  CXPrintingPolicy_Indentation* :enum_CXPrintingPolicyProperty= 0
  CXPrintingPolicy_SuppressSpecifiers* :enum_CXPrintingPolicyProperty= 1
  CXPrintingPolicy_SuppressTagKeyword* :enum_CXPrintingPolicyProperty= 2
  CXPrintingPolicy_IncludeTagDefinition* :enum_CXPrintingPolicyProperty= 3
  CXPrintingPolicy_SuppressScope* :enum_CXPrintingPolicyProperty= 4
  CXPrintingPolicy_SuppressUnwrittenScope* :enum_CXPrintingPolicyProperty= 5
  CXPrintingPolicy_SuppressInitializers* :enum_CXPrintingPolicyProperty= 6
  CXPrintingPolicy_ConstantArraySizeAsWritten* :enum_CXPrintingPolicyProperty= 7
  CXPrintingPolicy_AnonymousTagLocations* :enum_CXPrintingPolicyProperty= 8
  CXPrintingPolicy_SuppressStrongLifetime* :enum_CXPrintingPolicyProperty= 9
  CXPrintingPolicy_SuppressLifetimeQualifiers* :enum_CXPrintingPolicyProperty= 10
  CXPrintingPolicy_SuppressTemplateArgsInCXXConstructors* :enum_CXPrintingPolicyProperty= 11
  CXPrintingPolicy_Bool* :enum_CXPrintingPolicyProperty= 12
  CXPrintingPolicy_Restrict* :enum_CXPrintingPolicyProperty= 13
  CXPrintingPolicy_Alignof* :enum_CXPrintingPolicyProperty= 14
  CXPrintingPolicy_UnderscoreAlignof* :enum_CXPrintingPolicyProperty= 15
  CXPrintingPolicy_UseVoidForZeroParams* :enum_CXPrintingPolicyProperty= 16
  CXPrintingPolicy_TerseOutput* :enum_CXPrintingPolicyProperty= 17
  CXPrintingPolicy_PolishForDeclaration* :enum_CXPrintingPolicyProperty= 18
  CXPrintingPolicy_Half* :enum_CXPrintingPolicyProperty= 19
  CXPrintingPolicy_MSWChar* :enum_CXPrintingPolicyProperty= 20
  CXPrintingPolicy_IncludeNewlines* :enum_CXPrintingPolicyProperty= 21
  CXPrintingPolicy_MSVCFormatting* :enum_CXPrintingPolicyProperty= 22
  CXPrintingPolicy_ConstantsAsWritten* :enum_CXPrintingPolicyProperty= 23
  CXPrintingPolicy_SuppressImplicitBase* :enum_CXPrintingPolicyProperty= 24
  CXPrintingPolicy_FullyQualifiedName* :enum_CXPrintingPolicyProperty= 25
  CXPrintingPolicy_LastProperty* :enum_CXPrintingPolicyProperty= 25
type CXPrintingPolicyProperty* = enum_CXPrintingPolicyProperty
## 
## Get a property value for the given printing policy.
proc clang_PrintingPolicy_getProperty*(Policy :CXPrintingPolicy; Property :CXPrintingPolicyProperty) :cuint {.importc:"clang_PrintingPolicy_getProperty", cdecl, dynlib:libclang.}
## 
## Set a property value for the given printing policy.
proc clang_PrintingPolicy_setProperty*(Policy :CXPrintingPolicy; Property :CXPrintingPolicyProperty; Value :cuint) {.importc:"clang_PrintingPolicy_setProperty", cdecl, dynlib:libclang.}
## 
## Retrieve the default policy for the cursor.
## 
## The policy should be released after use with \c
## clang_PrintingPolicy_dispose.
proc clang_getCursorPrintingPolicy*(a0 :CXCursor) :CXPrintingPolicy {.importc:"clang_getCursorPrintingPolicy", cdecl, dynlib:libclang.}
## 
## Release a printing policy.
proc clang_PrintingPolicy_dispose*(Policy :CXPrintingPolicy) {.importc:"clang_PrintingPolicy_dispose", cdecl, dynlib:libclang.}
## 
## Pretty print declarations.
## 
## \param Cursor The cursor representing a declaration.
## 
## \param Policy The policy to control the entities being printed. If
## NULL, a default policy is used.
## 
## \returns The pretty printed declaration or the empty string for
## other cursors.
proc clang_getCursorPrettyPrinted*(Cursor :CXCursor; Policy :CXPrintingPolicy) :CXString {.importc:"clang_getCursorPrettyPrinted", cdecl, dynlib:libclang.}
## 
## Retrieve the display name for the entity referenced by this cursor.
## 
## The display name contains extra information that helps identify the cursor,
## such as the parameters of a function or template or the arguments of a
## class template specialization.
proc clang_getCursorDisplayName*(a0 :CXCursor) :CXString {.importc:"clang_getCursorDisplayName", cdecl, dynlib:libclang.}
## For a cursor that is a reference, retrieve a cursor representing the
## entity that it references.
## 
## Reference cursors refer to other entities in the AST. For example, an
## Objective-C superclass reference cursor refers to an Objective-C class.
## This function produces the cursor for the Objective-C class from the
## cursor for the superclass reference. If the input cursor is a declaration or
## definition, it returns that declaration or definition unchanged.
## Otherwise, returns the NULL cursor.
proc clang_getCursorReferenced*(a0 :CXCursor) :CXCursor {.importc:"clang_getCursorReferenced", cdecl, dynlib:libclang.}
## 
##  For a cursor that is either a reference to or a declaration
##  of some entity, retrieve a cursor that describes the definition of
##  that entity.
## 
##  Some entities can be declared multiple times within a translation
##  unit, but only one of those declarations can also be a
##  definition. For example, given:
## 
##  \code
##  int f(int, int);
##  int g(int x, int y) { return f(x, y); }
##  int f(int a, int b) { return a + b; }
##  int f(int, int);
##  \endcode
## 
##  there are three declarations of the function "f", but only the
##  second one is a definition. The clang_getCursorDefinition()
##  function will take any cursor pointing to a declaration of "f"
##  (the first or fourth lines of the example) or a cursor referenced
##  that uses "f" (the call to "f' inside "g") and will return a
##  declaration cursor pointing to the definition (the second "f"
##  declaration).
## 
##  If given a cursor for which there is no corresponding definition,
##  e.g., because there is no definition of that entity within this
##  translation unit, returns a NULL cursor.
proc clang_getCursorDefinition*(a0 :CXCursor) :CXCursor {.importc:"clang_getCursorDefinition", cdecl, dynlib:libclang.}
## 
## Determine whether the declaration pointed to by this cursor
## is also a definition of that entity.
proc clang_isCursorDefinition*(a0 :CXCursor) :cuint {.importc:"clang_isCursorDefinition", cdecl, dynlib:libclang.}
## 
## Retrieve the canonical cursor corresponding to the given cursor.
## 
## In the C family of languages, many kinds of entities can be declared several
## times within a single translation unit. For example, a structure type can
## be forward-declared (possibly multiple times) and later defined:
## 
## \code
## struct X;
## struct X;
## struct X {
##   int member;
## };
## \endcode
## 
## The declarations and the definition of X are represented by three
## different cursors, all of which are declarations of the same underlying
## entity. One of these cursor is considered the "canonical" cursor, which
## is effectively the representative for the underlying entity. One can
## determine if two cursors are declarations of the same underlying entity by
## comparing their canonical cursors.
## 
## \returns The canonical cursor for the entity referred to by the given cursor.
proc clang_getCanonicalCursor*(a0 :CXCursor) :CXCursor {.importc:"clang_getCanonicalCursor", cdecl, dynlib:libclang.}
## 
## If the cursor points to a selector identifier in an Objective-C
## method or message expression, this returns the selector index.
## 
## After getting a cursor with #clang_getCursor, this can be called to
## determine if the location points to a selector identifier.
## 
## \returns The selector index if the cursor is an Objective-C method or message
## expression and the cursor is pointing to a selector identifier, or -1
## otherwise.
proc clang_Cursor_getObjCSelectorIndex*(a0 :CXCursor) :cint {.importc:"clang_Cursor_getObjCSelectorIndex", cdecl, dynlib:libclang.}
## 
## Given a cursor pointing to a C++ method call or an Objective-C
## message, returns non-zero if the method/message is "dynamic", meaning:
## 
## For a C++ method: the call is virtual.
## For an Objective-C message: the receiver is an object instance, not 'super'
## or a specific class.
## 
## If the method/message is "static" or the cursor does not point to a
## method/message, it will return zero.
proc clang_Cursor_isDynamicCall*(C :CXCursor) :cint {.importc:"clang_Cursor_isDynamicCall", cdecl, dynlib:libclang.}
## 
## Given a cursor pointing to an Objective-C message or property
## reference, or C++ method call, returns the CXType of the receiver.
proc clang_Cursor_getReceiverType*(C :CXCursor) :CXType {.importc:"clang_Cursor_getReceiverType", cdecl, dynlib:libclang.}
## 
## Property attributes for a CXCursor_ObjCPropertyDecl.
type enum_CXObjCPropertyAttrKind* = cint
const
  CXObjCPropertyAttr_noattr* :enum_CXObjCPropertyAttrKind= 0
  CXObjCPropertyAttr_readonly* :enum_CXObjCPropertyAttrKind= 1
  CXObjCPropertyAttr_getter* :enum_CXObjCPropertyAttrKind= 2
  CXObjCPropertyAttr_assign* :enum_CXObjCPropertyAttrKind= 4
  CXObjCPropertyAttr_readwrite* :enum_CXObjCPropertyAttrKind= 8
  CXObjCPropertyAttr_retain* :enum_CXObjCPropertyAttrKind= 16
  CXObjCPropertyAttr_copy* :enum_CXObjCPropertyAttrKind= 32
  CXObjCPropertyAttr_nonatomic* :enum_CXObjCPropertyAttrKind= 64
  CXObjCPropertyAttr_setter* :enum_CXObjCPropertyAttrKind= 128
  CXObjCPropertyAttr_atomic* :enum_CXObjCPropertyAttrKind= 256
  CXObjCPropertyAttr_weak* :enum_CXObjCPropertyAttrKind= 512
  CXObjCPropertyAttr_strong* :enum_CXObjCPropertyAttrKind= 1024
  CXObjCPropertyAttr_unsafe_unretained* :enum_CXObjCPropertyAttrKind= 2048
  CXObjCPropertyAttr_class* :enum_CXObjCPropertyAttrKind= 4096
type CXObjCPropertyAttrKind* = enum_CXObjCPropertyAttrKind
## 
## Given a cursor that represents a property declaration, return the
## associated property attributes. The bits are formed from
## CXObjCPropertyAttrKind.
## 
## \param reserved Reserved for future use, pass 0.
proc clang_Cursor_getObjCPropertyAttributes*(C :CXCursor; reserved :cuint) :cuint {.importc:"clang_Cursor_getObjCPropertyAttributes", cdecl, dynlib:libclang.}
## 
## Given a cursor that represents a property declaration, return the
## name of the method that implements the getter.
proc clang_Cursor_getObjCPropertyGetterName*(C :CXCursor) :CXString {.importc:"clang_Cursor_getObjCPropertyGetterName", cdecl, dynlib:libclang.}
## 
## Given a cursor that represents a property declaration, return the
## name of the method that implements the setter, if any.
proc clang_Cursor_getObjCPropertySetterName*(C :CXCursor) :CXString {.importc:"clang_Cursor_getObjCPropertySetterName", cdecl, dynlib:libclang.}
## 
## 'Qualifiers' written next to the return and parameter types in
## Objective-C method declarations.
type enum_CXObjCDeclQualifierKind* = cint
const
  CXObjCDeclQualifier_None* :enum_CXObjCDeclQualifierKind= 0
  CXObjCDeclQualifier_In* :enum_CXObjCDeclQualifierKind= 1
  CXObjCDeclQualifier_Inout* :enum_CXObjCDeclQualifierKind= 2
  CXObjCDeclQualifier_Out* :enum_CXObjCDeclQualifierKind= 4
  CXObjCDeclQualifier_Bycopy* :enum_CXObjCDeclQualifierKind= 8
  CXObjCDeclQualifier_Byref* :enum_CXObjCDeclQualifierKind= 16
  CXObjCDeclQualifier_Oneway* :enum_CXObjCDeclQualifierKind= 32
type CXObjCDeclQualifierKind* = enum_CXObjCDeclQualifierKind
## 
## Given a cursor that represents an Objective-C method or parameter
## declaration, return the associated Objective-C qualifiers for the return
## type or the parameter respectively. The bits are formed from
## CXObjCDeclQualifierKind.
proc clang_Cursor_getObjCDeclQualifiers*(C :CXCursor) :cuint {.importc:"clang_Cursor_getObjCDeclQualifiers", cdecl, dynlib:libclang.}
## 
## Given a cursor that represents an Objective-C method or property
## declaration, return non-zero if the declaration was affected by "\@optional".
## Returns zero if the cursor is not such a declaration or it is "\@required".
proc clang_Cursor_isObjCOptional*(C :CXCursor) :cuint {.importc:"clang_Cursor_isObjCOptional", cdecl, dynlib:libclang.}
## 
## Returns non-zero if the given cursor is a variadic function or method.
proc clang_Cursor_isVariadic*(C :CXCursor) :cuint {.importc:"clang_Cursor_isVariadic", cdecl, dynlib:libclang.}
## 
## Returns non-zero if the given cursor points to a symbol marked with
## external_source_symbol attribute.
## 
## \param language If non-NULL, and the attribute is present, will be set to
## the 'language' string from the attribute.
## 
## \param definedIn If non-NULL, and the attribute is present, will be set to
## the 'definedIn' string from the attribute.
## 
## \param isGenerated If non-NULL, and the attribute is present, will be set to
## non-zero if the 'generated_declaration' is set in the attribute.
proc clang_Cursor_isExternalSymbol*(C :CXCursor; language :ptr CXString; definedIn :ptr CXString; isGenerated :ptr cuint) :cuint {.importc:"clang_Cursor_isExternalSymbol", cdecl, dynlib:libclang.}
## 
## Given a cursor that represents a declaration, return the associated
## comment's source range.  The range may include multiple consecutive comments
## with whitespace in between.
proc clang_Cursor_getCommentRange*(C :CXCursor) :CXSourceRange {.importc:"clang_Cursor_getCommentRange", cdecl, dynlib:libclang.}
## 
## Given a cursor that represents a declaration, return the associated
## comment text, including comment markers.
proc clang_Cursor_getRawCommentText*(C :CXCursor) :CXString {.importc:"clang_Cursor_getRawCommentText", cdecl, dynlib:libclang.}
## 
## Given a cursor that represents a documentable entity (e.g.,
## declaration), return the associated \paragraph; otherwise return the
## first paragraph.
proc clang_Cursor_getBriefCommentText*(C :CXCursor) :CXString {.importc:"clang_Cursor_getBriefCommentText", cdecl, dynlib:libclang.}
## 
## Retrieve the CXString representing the mangled name of the cursor.
proc clang_Cursor_getMangling*(a0 :CXCursor) :CXString {.importc:"clang_Cursor_getMangling", cdecl, dynlib:libclang.}
## 
## Retrieve the CXStrings representing the mangled symbols of the C++
## constructor or destructor at the cursor.
proc clang_Cursor_getCXXManglings*(a0 :CXCursor) :ptr CXStringSet {.importc:"clang_Cursor_getCXXManglings", cdecl, dynlib:libclang.}
## 
## Retrieve the CXStrings representing the mangled symbols of the ObjC
## class interface or implementation at the cursor.
proc clang_Cursor_getObjCManglings*(a0 :CXCursor) :ptr CXStringSet {.importc:"clang_Cursor_getObjCManglings", cdecl, dynlib:libclang.}
## 
## \defgroup CINDEX_MODULE Module introspection
## 
## The functions in this group provide access to information about modules.
## 
## @{
type CXModule* = pointer
## 
## Given a CXCursor_ModuleImportDecl cursor, return the associated module.
proc clang_Cursor_getModule*(C :CXCursor) :CXModule {.importc:"clang_Cursor_getModule", cdecl, dynlib:libclang.}
## 
## Given a CXFile header file, return the module that contains it, if one
## exists.
proc clang_getModuleForFile*(a0 :CXTranslationUnit; a1 :CXFile) :CXModule {.importc:"clang_getModuleForFile", cdecl, dynlib:libclang.}
## 
## \param Module a module object.
## 
## \returns the module file where the provided module object came from.
proc clang_Module_getASTFile*(Module :CXModule) :CXFile {.importc:"clang_Module_getASTFile", cdecl, dynlib:libclang.}
## 
## \param Module a module object.
## 
## \returns the parent of a sub-module or NULL if the given module is top-level,
## e.g. for 'std.vector' it will return the 'std' module.
proc clang_Module_getParent*(Module :CXModule) :CXModule {.importc:"clang_Module_getParent", cdecl, dynlib:libclang.}
## 
## \param Module a module object.
## 
## \returns the name of the module, e.g. for the 'std.vector' sub-module it
## will return "vector".
proc clang_Module_getName*(Module :CXModule) :CXString {.importc:"clang_Module_getName", cdecl, dynlib:libclang.}
## 
## \param Module a module object.
## 
## \returns the full name of the module, e.g. "std.vector".
proc clang_Module_getFullName*(Module :CXModule) :CXString {.importc:"clang_Module_getFullName", cdecl, dynlib:libclang.}
## 
## \param Module a module object.
## 
## \returns non-zero if the module is a system one.
proc clang_Module_isSystem*(Module :CXModule) :cint {.importc:"clang_Module_isSystem", cdecl, dynlib:libclang.}
## 
## \param Module a module object.
## 
## \returns the number of top level headers associated with this module.
proc clang_Module_getNumTopLevelHeaders*(a0 :CXTranslationUnit; Module :CXModule) :cuint {.importc:"clang_Module_getNumTopLevelHeaders", cdecl, dynlib:libclang.}
## 
## \param Module a module object.
## 
## \param Index top level header index (zero-based).
## 
## \returns the specified top level header associated with the module.
proc clang_Module_getTopLevelHeader*(a0 :CXTranslationUnit; Module :CXModule; Index :cuint) :CXFile {.importc:"clang_Module_getTopLevelHeader", cdecl, dynlib:libclang.}
## 
## Determine if a C++ constructor is a converting constructor.
proc clang_CXXConstructor_isConvertingConstructor*(C :CXCursor) :cuint {.importc:"clang_CXXConstructor_isConvertingConstructor", cdecl, dynlib:libclang.}
## 
## Determine if a C++ constructor is a copy constructor.
proc clang_CXXConstructor_isCopyConstructor*(C :CXCursor) :cuint {.importc:"clang_CXXConstructor_isCopyConstructor", cdecl, dynlib:libclang.}
## 
## Determine if a C++ constructor is the default constructor.
proc clang_CXXConstructor_isDefaultConstructor*(C :CXCursor) :cuint {.importc:"clang_CXXConstructor_isDefaultConstructor", cdecl, dynlib:libclang.}
## 
## Determine if a C++ constructor is a move constructor.
proc clang_CXXConstructor_isMoveConstructor*(C :CXCursor) :cuint {.importc:"clang_CXXConstructor_isMoveConstructor", cdecl, dynlib:libclang.}
## 
## Determine if a C++ field is declared 'mutable'.
proc clang_CXXField_isMutable*(C :CXCursor) :cuint {.importc:"clang_CXXField_isMutable", cdecl, dynlib:libclang.}
## 
## Determine if a C++ method is declared '= default'.
proc clang_CXXMethod_isDefaulted*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isDefaulted", cdecl, dynlib:libclang.}
## 
## Determine if a C++ method is declared '= delete'.
proc clang_CXXMethod_isDeleted*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isDeleted", cdecl, dynlib:libclang.}
## 
## Determine if a C++ member function or member function template is
## pure virtual.
proc clang_CXXMethod_isPureVirtual*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isPureVirtual", cdecl, dynlib:libclang.}
## 
## Determine if a C++ member function or member function template is
## declared 'static'.
proc clang_CXXMethod_isStatic*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isStatic", cdecl, dynlib:libclang.}
## 
## Determine if a C++ member function or member function template is
## explicitly declared 'virtual' or if it overrides a virtual method from
## one of the base classes.
proc clang_CXXMethod_isVirtual*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isVirtual", cdecl, dynlib:libclang.}
## 
## Determine if a C++ member function is a copy-assignment operator,
## returning 1 if such is the case and 0 otherwise.
## 
## > A copy-assignment operator `X::operator=` is a non-static,
## > non-template member function of _class_ `X` with exactly one
## > parameter of type `X`, `X&`, `const X&`, `volatile X&` or `const
## > volatile X&`.
## 
## That is, for example, the `operator=` in:
## 
##    class Foo {
##        bool operator=(const volatile Foo&);
##    };
## 
## Is a copy-assignment operator, while the `operator=` in:
## 
##    class Bar {
##        bool operator=(const int&);
##    };
## 
## Is not.
proc clang_CXXMethod_isCopyAssignmentOperator*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isCopyAssignmentOperator", cdecl, dynlib:libclang.}
## 
## Determine if a C++ member function is a move-assignment operator,
## returning 1 if such is the case and 0 otherwise.
## 
## > A move-assignment operator `X::operator=` is a non-static,
## > non-template member function of _class_ `X` with exactly one
## > parameter of type `X&&`, `const X&&`, `volatile X&&` or `const
## > volatile X&&`.
## 
## That is, for example, the `operator=` in:
## 
##    class Foo {
##        bool operator=(const volatile Foo&&);
##    };
## 
## Is a move-assignment operator, while the `operator=` in:
## 
##    class Bar {
##        bool operator=(const int&&);
##    };
## 
## Is not.
proc clang_CXXMethod_isMoveAssignmentOperator*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isMoveAssignmentOperator", cdecl, dynlib:libclang.}
## 
## Determines if a C++ constructor or conversion function was declared
## explicit, returning 1 if such is the case and 0 otherwise.
## 
## Constructors or conversion functions are declared explicit through
## the use of the explicit specifier.
## 
## For example, the following constructor and conversion function are
## not explicit as they lack the explicit specifier:
## 
##     class Foo {
##         Foo();
##         operator int();
##     };
## 
## While the following constructor and conversion function are
## explicit as they are declared with the explicit specifier.
## 
##     class Foo {
##         explicit Foo();
##         explicit operator int();
##     };
## 
## This function will return 0 when given a cursor pointing to one of
## the former declarations and it will return 1 for a cursor pointing
## to the latter declarations.
## 
## The explicit specifier allows the user to specify a
## conditional compile-time expression whose value decides
## whether the marked element is explicit or not.
## 
## For example:
## 
##     constexpr bool foo(int i) { return i % 2 == 0; }
## 
##     class Foo {
##          explicit(foo(1)) Foo();
##          explicit(foo(2)) operator int();
##     }
## 
## This function will return 0 for the constructor and 1 for
## the conversion function.
proc clang_CXXMethod_isExplicit*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isExplicit", cdecl, dynlib:libclang.}
## 
## Determine if a C++ record is abstract, i.e. whether a class or struct
## has a pure virtual member function.
proc clang_CXXRecord_isAbstract*(C :CXCursor) :cuint {.importc:"clang_CXXRecord_isAbstract", cdecl, dynlib:libclang.}
## 
## Determine if an enum declaration refers to a scoped enum.
proc clang_EnumDecl_isScoped*(C :CXCursor) :cuint {.importc:"clang_EnumDecl_isScoped", cdecl, dynlib:libclang.}
## 
## Determine if a C++ member function or member function template is
## declared 'const'.
proc clang_CXXMethod_isConst*(C :CXCursor) :cuint {.importc:"clang_CXXMethod_isConst", cdecl, dynlib:libclang.}
## 
## Given a cursor that represents a template, determine
## the cursor kind of the specializations would be generated by instantiating
## the template.
## 
## This routine can be used to determine what flavor of function template,
## class template, or class template partial specialization is stored in the
## cursor. For example, it can describe whether a class template cursor is
## declared with "struct", "class" or "union".
## 
## \param C The cursor to query. This cursor should represent a template
## declaration.
## 
## \returns The cursor kind of the specializations that would be generated
## by instantiating the template C. If C is not a template, returns
## CXCursor_NoDeclFound.
proc clang_getTemplateCursorKind*(C :CXCursor) :CXCursorKind {.importc:"clang_getTemplateCursorKind", cdecl, dynlib:libclang.}
## 
## Given a cursor that may represent a specialization or instantiation
## of a template, retrieve the cursor that represents the template that it
## specializes or from which it was instantiated.
## 
## This routine determines the template involved both for explicit
## specializations of templates and for implicit instantiations of the template,
## both of which are referred to as "specializations". For a class template
## specialization (e.g., std::vector<bool>), this routine will return
## either the primary template (std::vector) or, if the specialization was
## instantiated from a class template partial specialization, the class template
## partial specialization. For a class template partial specialization and a
## function template specialization (including instantiations), this
## this routine will return the specialized template.
## 
## For members of a class template (e.g., member functions, member classes, or
## static data members), returns the specialized or instantiated member.
## Although not strictly "templates" in the C++ language, members of class
## templates have the same notions of specializations and instantiations that
## templates do, so this routine treats them similarly.
## 
## \param C A cursor that may be a specialization of a template or a member
## of a template.
## 
## \returns If the given cursor is a specialization or instantiation of a
## template or a member thereof, the template or member that it specializes or
## from which it was instantiated. Otherwise, returns a NULL cursor.
proc clang_getSpecializedCursorTemplate*(C :CXCursor) :CXCursor {.importc:"clang_getSpecializedCursorTemplate", cdecl, dynlib:libclang.}
## 
## Given a cursor that references something else, return the source range
## covering that reference.
## 
## \param C A cursor pointing to a member reference, a declaration reference, or
## an operator call.
## \param NameFlags A bitset with three independent flags:
## CXNameRange_WantQualifier, CXNameRange_WantTemplateArgs, and
## CXNameRange_WantSinglePiece.
## \param PieceIndex For contiguous names or when passing the flag
## CXNameRange_WantSinglePiece, only one piece with index 0 is
## available. When the CXNameRange_WantSinglePiece flag is not passed for a
## non-contiguous names, this index can be used to retrieve the individual
## pieces of the name. See also CXNameRange_WantSinglePiece.
## 
## \returns The piece of the name pointed to by the given cursor. If there is no
## name, or if the PieceIndex is out-of-range, a null-cursor will be returned.
proc clang_getCursorReferenceNameRange*(C :CXCursor; NameFlags :cuint; PieceIndex :cuint) :CXSourceRange {.importc:"clang_getCursorReferenceNameRange", cdecl, dynlib:libclang.}
type enum_CXNameRefFlags* = cint
const
  CXNameRange_WantQualifier* :enum_CXNameRefFlags= 1
  CXNameRange_WantTemplateArgs* :enum_CXNameRefFlags= 2
  CXNameRange_WantSinglePiece* :enum_CXNameRefFlags= 4
type CXNameRefFlags* = enum_CXNameRefFlags
## 
## Describes a kind of token.
type enum_CXTokenKind* = cint
const
  CXToken_Punctuation* :enum_CXTokenKind= 0
  CXToken_Keyword* :enum_CXTokenKind= 1
  CXToken_Identifier* :enum_CXTokenKind= 2
  CXToken_Literal* :enum_CXTokenKind= 3
  CXToken_Comment* :enum_CXTokenKind= 4
type CXTokenKind* = enum_CXTokenKind
## 
## Describes a single preprocessing token.
type anonica* {.lized .} = object
  e.
The v* :array[l, irtua]
   path mu* :st be c
## 
## Get the raw lexical token starting with the given location.
## 
## \param TU the translation unit whose text is being tokenized.
## 
## \param Location the source location with which the token starts.
## 
## \returns The token starting with the given location or NULL if no such token
## exist. The returned pointer must be freed with clang_disposeTokens before the
## translation unit is destroyed.
proc clang_getToken*(TU :CXTranslationUnit; Location :CXSourceLocation) :ptr CXToken {.importc:"clang_getToken", cdecl, dynlib:libclang.}
## 
## Determine the kind of the given token.
proc clang_getTokenKind*(a0 :CXToken) :CXTokenKind {.importc:"clang_getTokenKind", cdecl, dynlib:libclang.}
## 
## Determine the spelling of the given token.
## 
## The spelling of a token is the textual representation of that token, e.g.,
## the text of an identifier or keyword.
proc clang_getTokenSpelling*(a0 :CXTranslationUnit; a1 :CXToken) :CXString {.importc:"clang_getTokenSpelling", cdecl, dynlib:libclang.}
## 
## Retrieve the source location of the given token.
proc clang_getTokenLocation*(a0 :CXTranslationUnit; a1 :CXToken) :CXSourceLocation {.importc:"clang_getTokenLocation", cdecl, dynlib:libclang.}
## 
## Retrieve a source range that covers the given token.
proc clang_getTokenExtent*(a0 :CXTranslationUnit; a1 :CXToken) :CXSourceRange {.importc:"clang_getTokenExtent", cdecl, dynlib:libclang.}
## 
## Tokenize the source code described by the given range into raw
## lexical tokens.
## 
## \param TU the translation unit whose text is being tokenized.
## 
## \param Range the source range in which text should be tokenized. All of the
## tokens produced by tokenization will fall within this source range,
## 
## \param Tokens this pointer will be set to point to the array of tokens
## that occur within the given source range. The returned pointer must be
## freed with clang_disposeTokens() before the translation unit is destroyed.
## 
## \param NumTokens will be set to the number of tokens in the *Tokens
## array.
proc clang_tokenize*(TU :CXTranslationUnit; Range :CXSourceRange; Tokens :ptr ptr CXToken; NumTokens :ptr cuint) {.importc:"clang_tokenize", cdecl, dynlib:libclang.}
## 
## Annotate the given set of tokens by providing cursors for each token
## that can be mapped to a specific entity within the abstract syntax tree.
## 
## This token-annotation routine is equivalent to invoking
## clang_getCursor() for the source locations of each of the
## tokens. The cursors provided are filtered, so that only those
## cursors that have a direct correspondence to the token are
## accepted. For example, given a function call f(x),
## clang_getCursor() would provide the following cursors:
## 
##   * when the cursor is over the 'f', a DeclRefExpr cursor referring to 'f'.
##   * when the cursor is over the '(' or the ')', a CallExpr referring to 'f'.
##   * when the cursor is over the 'x', a DeclRefExpr cursor referring to 'x'.
## 
## Only the first and last of these cursors will occur within the
## annotate, since the tokens "f" and "x' directly refer to a function
## and a variable, respectively, but the parentheses are just a small
## part of the full syntax of the function call expression, which is
## not provided as an annotation.
## 
## \param TU the translation unit that owns the given tokens.
## 
## \param Tokens the set of tokens to annotate.
## 
## \param NumTokens the number of tokens in Tokens.
## 
## \param Cursors an array of NumTokens cursors, whose contents will be
## replaced with the cursors corresponding to each token.
proc clang_annotateTokens*(TU :CXTranslationUnit; Tokens :ptr CXToken; NumTokens :cuint; Cursors :ptr CXCursor) {.importc:"clang_annotateTokens", cdecl, dynlib:libclang.}
## 
## Free the given set of tokens.
proc clang_disposeTokens*(TU :CXTranslationUnit; Tokens :ptr CXToken; NumTokens :cuint) {.importc:"clang_disposeTokens", cdecl, dynlib:libclang.}
## 
## \defgroup CINDEX_DEBUG Debugging facilities
## 
## These routines are used for testing and debugging, only, and should not
## be relied upon.
## 
## @{
proc clang_getCursorKindSpelling*(Kind :CXCursorKind) :CXString {.importc:"clang_getCursorKindSpelling", cdecl, dynlib:libclang.}
proc clang_getDefinitionSpellingAndExtent*(a0 :CXCursor; startBuf :ptr cstring; endBuf :ptr cstring; startLine :ptr cuint; startColumn :ptr cuint; endLine :ptr cuint; endColumn :ptr cuint) {.importc:"clang_getDefinitionSpellingAndExtent", cdecl, dynlib:libclang.}
proc clang_enableStackTraces*() {.importc:"clang_enableStackTraces", cdecl, dynlib:libclang.}
proc clang_executeOnThread*(fn :proc (a0 :pointer) {.cdecl.}; user_data :pointer; stack_size :cuint) {.importc:"clang_executeOnThread", cdecl, dynlib:libclang.}
## 
## A semantic string that describes a code-completion result.
## 
## A semantic string that describes the formatting of a code-completion
## result as a single "template" of text that should be inserted into the
## source buffer when a particular code-completion result is selected.
## Each semantic string is made up of some number of "chunks", each of which
## contains some text along with a description of what that text means, e.g.,
## the name of the entity being referenced, whether the text chunk is part of
## the template, or whether it is a "placeholder" that the user should replace
## with actual code,of a specific kind. See CXCompletionChunkKind for a
## description of the different kinds of chunks.
type CXCompletionString* = pointer
## 
## A single result of code completion.
type  to indicate an er* {.ror.cl.} = object
  (not conta* :in "."/"..")
  .
\returns 0 for* : success, non-zero
## 
## Describes a single piece of text within a code-completion string.
## 
## Each "chunk" within a code-completion string (CXCompletionString) is
## either a piece of text with a specific "kind" that describes how that text
## should be interpreted by the client or is another completion string.
type enum_CXCompletionChunkKind* = cint
const
  CXCompletionChunk_Optional* :enum_CXCompletionChunkKind= 0
  CXCompletionChunk_TypedText* :enum_CXCompletionChunkKind= 1
  CXCompletionChunk_Text* :enum_CXCompletionChunkKind= 2
  CXCompletionChunk_Placeholder* :enum_CXCompletionChunkKind= 3
  CXCompletionChunk_Informative* :enum_CXCompletionChunkKind= 4
  CXCompletionChunk_CurrentParameter* :enum_CXCompletionChunkKind= 5
  CXCompletionChunk_LeftParen* :enum_CXCompletionChunkKind= 6
  CXCompletionChunk_RightParen* :enum_CXCompletionChunkKind= 7
  CXCompletionChunk_LeftBracket* :enum_CXCompletionChunkKind= 8
  CXCompletionChunk_RightBracket* :enum_CXCompletionChunkKind= 9
  CXCompletionChunk_LeftBrace* :enum_CXCompletionChunkKind= 10
  CXCompletionChunk_RightBrace* :enum_CXCompletionChunkKind= 11
  CXCompletionChunk_LeftAngle* :enum_CXCompletionChunkKind= 12
  CXCompletionChunk_RightAngle* :enum_CXCompletionChunkKind= 13
  CXCompletionChunk_Comma* :enum_CXCompletionChunkKind= 14
  CXCompletionChunk_ResultType* :enum_CXCompletionChunkKind= 15
  CXCompletionChunk_Colon* :enum_CXCompletionChunkKind= 16
  CXCompletionChunk_SemiColon* :enum_CXCompletionChunkKind= 17
  CXCompletionChunk_Equal* :enum_CXCompletionChunkKind= 18
  CXCompletionChunk_HorizontalSpace* :enum_CXCompletionChunkKind= 19
  CXCompletionChunk_VerticalSpace* :enum_CXCompletionChunkKind= 20
type CXCompletionChunkKind* = enum_CXCompletionChunkKind
## 
## Determine the kind of a particular chunk within a completion string.
## 
## \param completion_string the completion string to query.
## 
## \param chunk_number the 0-based index of the chunk in the completion string.
## 
## \returns the kind of the chunk at the index chunk_number.
proc clang_getCompletionChunkKind*(completion_string :CXCompletionString; chunk_number :cuint) :CXCompletionChunkKind {.importc:"clang_getCompletionChunkKind", cdecl, dynlib:libclang.}
## 
## Retrieve the text associated with a particular chunk within a
## completion string.
## 
## \param completion_string the completion string to query.
## 
## \param chunk_number the 0-based index of the chunk in the completion string.
## 
## \returns the text associated with the chunk at index chunk_number.
proc clang_getCompletionChunkText*(completion_string :CXCompletionString; chunk_number :cuint) :CXString {.importc:"clang_getCompletionChunkText", cdecl, dynlib:libclang.}
## 
## Retrieve the completion string associated with a particular chunk
## within a completion string.
## 
## \param completion_string the completion string to query.
## 
## \param chunk_number the 0-based index of the chunk in the completion string.
## 
## \returns the completion string associated with the chunk at index
## chunk_number.
proc clang_getCompletionChunkCompletionString*(completion_string :CXCompletionString; chunk_number :cuint) :CXCompletionString {.importc:"clang_getCompletionChunkCompletionString", cdecl, dynlib:libclang.}
## 
## Retrieve the number of chunks in the given code-completion string.
proc clang_getNumCompletionChunks*(completion_string :CXCompletionString) :cuint {.importc:"clang_getNumCompletionChunks", cdecl, dynlib:libclang.}
## 
## Determine the priority of this code completion.
## 
## The priority of a code completion indicates how likely it is that this
## particular completion is the completion that the user will select. The
## priority is selected by various internal heuristics.
## 
## \param completion_string The completion string to query.
## 
## \returns The priority of this completion string. Smaller values indicate
## higher-priority (more likely) completions.
proc clang_getCompletionPriority*(completion_string :CXCompletionString) :cuint {.importc:"clang_getCompletionPriority", cdecl, dynlib:libclang.}
## 
## Determine the availability of the entity that this code-completion
## string refers to.
## 
## \param completion_string The completion string to query.
## 
## \returns The availability of the completion string.
proc clang_getCompletionAvailability*(completion_string :CXCompletionString) :CXAvailabilityKind {.importc:"clang_getCompletionAvailability", cdecl, dynlib:libclang.}
## 
## Retrieve the number of annotations associated with the given
## completion string.
## 
## \param completion_string the completion string to query.
## 
## \returns the number of annotations associated with the given completion
## string.
proc clang_getCompletionNumAnnotations*(completion_string :CXCompletionString) :cuint {.importc:"clang_getCompletionNumAnnotations", cdecl, dynlib:libclang.}
## 
## Retrieve the annotation associated with the given completion string.
## 
## \param completion_string the completion string to query.
## 
## \param annotation_number the 0-based index of the annotation of the
## completion string.
## 
## \returns annotation string associated with the completion at index
## annotation_number, or a NULL string if that annotation is not available.
proc clang_getCompletionAnnotation*(completion_string :CXCompletionString; annotation_number :cuint) :CXString {.importc:"clang_getCompletionAnnotation", cdecl, dynlib:libclang.}
## 
## Retrieve the parent context of the given completion string.
## 
## The parent context of a completion string is the semantic parent of
## the declaration (if any) that the code completion represents. For example,
## a code completion for an Objective-C method would have the method's class
## or protocol as its context.
## 
## \param completion_string The code completion string whose parent is
## being queried.
## 
## \param kind DEPRECATED: always set to CXCursor_NotImplemented if non-NULL.
## 
## \returns The name of the completion parent, e.g., "NSObject" if
## the completion string represents a method in the NSObject class.
proc clang_getCompletionParent*(completion_string :CXCompletionString; kind :ptr CXCursorKind) :CXString {.importc:"clang_getCompletionParent", cdecl, dynlib:libclang.}
## 
## Retrieve the brief documentation comment attached to the declaration
## that corresponds to the given completion string.
proc clang_getCompletionBriefComment*(completion_string :CXCompletionString) :CXString {.importc:"clang_getCompletionBriefComment", cdecl, dynlib:libclang.}
## 
## Retrieve a completion string for an arbitrary declaration or macro
## definition cursor.
## 
## \param cursor The cursor to query.
## 
## \returns A non-context-sensitive completion string for declaration and macro
## definition cursors, or NULL for other kinds of cursors.
proc clang_getCursorCompletionString*(cursor :CXCursor) :CXCompletionString {.importc:"clang_getCursorCompletionString", cdecl, dynlib:libclang.}
## 
## Contains the results of code-completion.
## 
## This data structure contains the results of code completion, as
## produced by clang_codeCompleteAt(). Its contents must be freed by
## clang_disposeCodeCompleteResults.
type yCXErrorCodea0CXVirtu* {.alFile.} = object
  ang_Vir* :ptr tualFileOverlay_se
  tCaseSensi* :tivit
## 
## Retrieve the number of fix-its for the given completion index.
## 
## Calling this makes sense only if CXCodeComplete_IncludeCompletionsWithFixIts
## option was set.
## 
## \param results The structure keeping all completion results
## 
## \param completion_index The index of the completion
## 
## \return The number of fix-its which must be applied before the completion at
## completion_index can be applied
proc clang_getCompletionNumFixIts*(results :ptr CXCodeCompleteResults; completion_index :cuint) :cuint {.importc:"clang_getCompletionNumFixIts", cdecl, dynlib:libclang.}
## 
## Fix-its that *must* be applied before inserting the text for the
## corresponding completion.
## 
## By default, clang_codeCompleteAt() only returns completions with empty
## fix-its. Extra completions with non-empty fix-its should be explicitly
## requested by setting CXCodeComplete_IncludeCompletionsWithFixIts.
## 
## For the clients to be able to compute position of the cursor after applying
## fix-its, the following conditions are guaranteed to hold for
## replacement_range of the stored fix-its:
##  - Ranges in the fix-its are guaranteed to never contain the completion
##  point (or identifier under completion point, if any) inside them, except
##  at the start or at the end of the range.
##  - If a fix-it range starts or ends with completion point (or starts or
##  ends after the identifier under completion point), it will contain at
##  least one character. It allows to unambiguously recompute completion
##  point after applying the fix-it.
## 
## The intuition is that provided fix-its change code around the identifier we
## complete, but are not allowed to touch the identifier itself or the
## completion point. One example of completions with corrections are the ones
## replacing '.' with '->' and vice versa:
## 
## std::unique_ptr<std::vector<int>> vec_ptr;
## In 'vec_ptr.^', one of the completions is 'push_back', it requires
## replacing '.' with '->'.
## In 'vec_ptr->^', one of the completions is 'release', it requires
## replacing '->' with '.'.
## 
## \param results The structure keeping all completion results
## 
## \param completion_index The index of the completion
## 
## \param fixit_index The index of the fix-it for the completion at
## completion_index
## 
## \param replacement_range The fix-it range that must be replaced before the
## completion at completion_index can be applied
## 
## \returns The fix-it string that must replace the code at replacement_range
## before the completion at completion_index can be applied
proc clang_getCompletionFixIt*(results :ptr CXCodeCompleteResults; completion_index :cuint; fixit_index :cuint; replacement_range :ptr CXSourceRange) :CXString {.importc:"clang_getCompletionFixIt", cdecl, dynlib:libclang.}
## 
## Flags that can be passed to clang_codeCompleteAt() to
## modify its behavior.
## 
## The enumerators in this enumeration can be bitwise-OR'd together to
## provide multiple options to clang_codeCompleteAt().
type enum_CXCodeComplete_Flags* = cint
const
  CXCodeComplete_IncludeMacros* :enum_CXCodeComplete_Flags= 1
  CXCodeComplete_IncludeCodePatterns* :enum_CXCodeComplete_Flags= 2
  CXCodeComplete_IncludeBriefComments* :enum_CXCodeComplete_Flags= 4
  CXCodeComplete_SkipPreamble* :enum_CXCodeComplete_Flags= 8
  CXCodeComplete_IncludeCompletionsWithFixIts* :enum_CXCodeComplete_Flags= 16
type CXCodeComplete_Flags* = enum_CXCodeComplete_Flags
## 
## Bits that represent the context under which completion is occurring.
## 
## The enumerators in this enumeration may be bitwise-OR'd together if multiple
## contexts are occurring simultaneously.
type enum_CXCompletionContext* = cint
const
  CXCompletionContext_Unexposed* :enum_CXCompletionContext= 0
  CXCompletionContext_AnyType* :enum_CXCompletionContext= 1
  CXCompletionContext_AnyValue* :enum_CXCompletionContext= 2
  CXCompletionContext_ObjCObjectValue* :enum_CXCompletionContext= 4
  CXCompletionContext_ObjCSelectorValue* :enum_CXCompletionContext= 8
  CXCompletionContext_CXXClassTypeValue* :enum_CXCompletionContext= 16
  CXCompletionContext_DotMemberAccess* :enum_CXCompletionContext= 32
  CXCompletionContext_ArrowMemberAccess* :enum_CXCompletionContext= 64
  CXCompletionContext_ObjCPropertyAccess* :enum_CXCompletionContext= 128
  CXCompletionContext_EnumTag* :enum_CXCompletionContext= 256
  CXCompletionContext_UnionTag* :enum_CXCompletionContext= 512
  CXCompletionContext_StructTag* :enum_CXCompletionContext= 1024
  CXCompletionContext_ClassTag* :enum_CXCompletionContext= 2048
  CXCompletionContext_Namespace* :enum_CXCompletionContext= 4096
  CXCompletionContext_NestedNameSpecifier* :enum_CXCompletionContext= 8192
  CXCompletionContext_ObjCInterface* :enum_CXCompletionContext= 16384
  CXCompletionContext_ObjCProtocol* :enum_CXCompletionContext= 32768
  CXCompletionContext_ObjCCategory* :enum_CXCompletionContext= 65536
  CXCompletionContext_ObjCInstanceMessage* :enum_CXCompletionContext= 131072
  CXCompletionContext_ObjCClassMessage* :enum_CXCompletionContext= 262144
  CXCompletionContext_ObjCSelectorName* :enum_CXCompletionContext= 524288
  CXCompletionContext_MacroName* :enum_CXCompletionContext= 1048576
  CXCompletionContext_NaturalLanguage* :enum_CXCompletionContext= 2097152
  CXCompletionContext_IncludedFile* :enum_CXCompletionContext= 4194304
  CXCompletionContext_Unknown* :enum_CXCompletionContext= 8388607
type CXCompletionContext* = enum_CXCompletionContext
## 
## Returns a default set of code-completion options that can be
## passed toclang_codeCompleteAt().
proc clang_defaultCodeCompleteOptions*() :cuint {.importc:"clang_defaultCodeCompleteOptions", cdecl, dynlib:libclang.}
## 
## Perform code completion at a given location in a translation unit.
## 
## This function performs code completion at a particular file, line, and
## column within source code, providing results that suggest potential
## code snippets based on the context of the completion. The basic model
## for code completion is that Clang will parse a complete source file,
## performing syntax checking up to the location where code-completion has
## been requested. At that point, a special code-completion token is passed
## to the parser, which recognizes this token and determines, based on the
## current location in the C/Objective-C/C++ grammar and the state of
## semantic analysis, what completions to provide. These completions are
## returned via a new CXCodeCompleteResults structure.
## 
## Code completion itself is meant to be triggered by the client when the
## user types punctuation characters or whitespace, at which point the
## code-completion location will coincide with the cursor. For example, if p
## is a pointer, code-completion might be triggered after the "-" and then
## after the ">" in p->. When the code-completion location is after the ">",
## the completion results will provide, e.g., the members of the struct that
## "p" points to. The client is responsible for placing the cursor at the
## beginning of the token currently being typed, then filtering the results
## based on the contents of the token. For example, when code-completing for
## the expression p->get, the client should provide the location just after
## the ">" (e.g., pointing at the "g") to this code-completion hook. Then, the
## client can filter the results based on the current token text ("get"), only
## showing those results that start with "get". The intent of this interface
## is to separate the relatively high-latency acquisition of code-completion
## results from the filtering of results on a per-character basis, which must
## have a lower latency.
## 
## \param TU The translation unit in which code-completion should
## occur. The source files for this translation unit need not be
## completely up-to-date (and the contents of those source files may
## be overridden via unsaved_files). Cursors referring into the
## translation unit may be invalidated by this invocation.
## 
## \param complete_filename The name of the source file where code
## completion should be performed. This filename may be any file
## included in the translation unit.
## 
## \param complete_line The line at which code-completion should occur.
## 
## \param complete_column The column at which code-completion should occur.
## Note that the column should point just after the syntactic construct that
## initiated code completion, and not in the middle of a lexical token.
## 
## \param unsaved_files the Files that have not yet been saved to disk
## but may be required for parsing or code completion, including the
## contents of those files.  The contents and name of these files (as
## specified by CXUnsavedFile) are copied when necessary, so the
## client only needs to guarantee their validity until the call to
## this function returns.
## 
## \param num_unsaved_files The number of unsaved file entries in \p
## unsaved_files.
## 
## \param options Extra options that control the behavior of code
## completion, expressed as a bitwise OR of the enumerators of the
## CXCodeComplete_Flags enumeration. The
## clang_defaultCodeCompleteOptions() function returns a default set
## of code-completion options.
## 
## \returns If successful, a new CXCodeCompleteResults structure
## containing code-completion results, which should eventually be
## freed with clang_disposeCodeCompleteResults(). If code
## completion fails, returns NULL.
proc clang_codeCompleteAt*(TU :CXTranslationUnit; complete_filename :cstring; complete_line :cuint; complete_column :cuint; unsaved_files :ptr struct_CXUnsavedFile; num_unsaved_files :cuint; options :cuint) :ptr CXCodeCompleteResults {.importc:"clang_codeCompleteAt", cdecl, dynlib:libclang.}
## 
## Sort the code-completion results in case-insensitive alphabetical
## order.
## 
## \param Results The set of results to sort.
## \param NumResults The number of results in Results.
proc clang_sortCodeCompletionResults*(Results :ptr CXCompletionResult; NumResults :cuint) {.importc:"clang_sortCodeCompletionResults", cdecl, dynlib:libclang.}
## 
## Free the given set of code-completion results.
proc clang_disposeCodeCompleteResults*(Results :ptr CXCodeCompleteResults) {.importc:"clang_disposeCodeCompleteResults", cdecl, dynlib:libclang.}
## 
## Determine the number of diagnostics produced prior to the
## location where code completion was performed.
proc clang_codeCompleteGetNumDiagnostics*(Results :ptr CXCodeCompleteResults) :cuint {.importc:"clang_codeCompleteGetNumDiagnostics", cdecl, dynlib:libclang.}
## 
## Retrieve a diagnostic associated with the given code completion.
## 
## \param Results the code completion results to query.
## \param Index the zero-based diagnostic number to retrieve.
## 
## \returns the requested diagnostic. This diagnostic must be freed
## via a call to clang_disposeDiagnostic().
proc clang_codeCompleteGetDiagnostic*(Results :ptr CXCodeCompleteResults; Index :cuint) :CXDiagnostic {.importc:"clang_codeCompleteGetDiagnostic", cdecl, dynlib:libclang.}
## 
## Determines what completions are appropriate for the context
## the given code completion.
## 
## \param Results the code completion results to query
## 
## \returns the kinds of completions that are appropriate for use
## along with the given code completion results.
proc clang_codeCompleteGetContexts*(Results :ptr CXCodeCompleteResults) :culonglong {.importc:"clang_codeCompleteGetContexts", cdecl, dynlib:libclang.}
## 
## Returns the cursor kind for the container for the current code
## completion context. The container is only guaranteed to be set for
## contexts where a container exists (i.e. member accesses or Objective-C
## message sends); if there is not a container, this function will return
## CXCursor_InvalidCode.
## 
## \param Results the code completion results to query
## 
## \param IsIncomplete on return, this value will be false if Clang has complete
## information about the container. If Clang does not have complete
## information, this value will be true.
## 
## \returns the container kind, or CXCursor_InvalidCode if there is not a
## container
proc clang_codeCompleteGetContainerKind*(Results :ptr CXCodeCompleteResults; IsIncomplete :ptr cuint) :CXCursorKind {.importc:"clang_codeCompleteGetContainerKind", cdecl, dynlib:libclang.}
## 
## Returns the USR for the container for the current code completion
## context. If there is not a container for the current context, this
## function will return the empty string.
## 
## \param Results the code completion results to query
## 
## \returns the USR for the container
proc clang_codeCompleteGetContainerUSR*(Results :ptr CXCodeCompleteResults) :CXString {.importc:"clang_codeCompleteGetContainerUSR", cdecl, dynlib:libclang.}
## 
## Returns the currently-entered selector for an Objective-C message
## send, formatted like "initWithFoo:bar:". Only guaranteed to return a
## non-empty string for CXCompletionContext_ObjCInstanceMessage and
## CXCompletionContext_ObjCClassMessage.
## 
## \param Results the code completion results to query
## 
## \returns the selector (or partial selector) that has been entered thus far
## for an Objective-C message send.
proc clang_codeCompleteGetObjCSelector*(Results :ptr CXCodeCompleteResults) :CXString {.importc:"clang_codeCompleteGetObjCSelector", cdecl, dynlib:libclang.}
## 
## Return a version string, suitable for showing to a user, but not
##        intended to be parsed (the format is not guaranteed to be stable).
proc clang_getClangVersion*() :CXString {.importc:"clang_getClangVersion", cdecl, dynlib:libclang.}
## 
## Enable/disable crash recovery.
## 
## \param isEnabled Flag to indicate if crash recovery is enabled.  A non-zero
##        value enables crash recovery, while 0 disables it.
proc clang_toggleCrashRecovery*(isEnabled :cuint) {.importc:"clang_toggleCrashRecovery", cdecl, dynlib:libclang.}
## 
## Visitor invoked for each file in a translation unit
##        (used with clang_getInclusions()).
## 
## This visitor function will be invoked by clang_getInclusions() for each
## file included (either at the top-level or by \#include directives) within
## a translation unit.  The first argument is the file being included, and
## the second and third arguments provide the inclusion stack.  The
## array is sorted in order of immediate inclusion.  For example,
## the first element refers to the location that included 'included_file'.
type CXInclusionVisitor* = proc (a0 :CXFile; a1 :ptr CXSourceLocation; a2 :cuint; a3 :CXClientData) {.cdecl.}
## 
## Visit the set of preprocessor inclusions in a translation unit.
##   The visitor function is called with the provided data for every included
##   file.  This does not include headers included by the PCH file (unless one
##   is inspecting the inclusions in the PCH file itself).
proc clang_getInclusions*(tu :CXTranslationUnit; visitor :CXInclusionVisitor; client_data :CXClientData) {.importc:"clang_getInclusions", cdecl, dynlib:libclang.}
type enum_CXEvalResultKind* = cint
const
  CXEval_Int* :enum_CXEvalResultKind= 1
  CXEval_Float* :enum_CXEvalResultKind= 2
  CXEval_ObjCStrLiteral* :enum_CXEvalResultKind= 3
  CXEval_StrLiteral* :enum_CXEvalResultKind= 4
  CXEval_CFStr* :enum_CXEvalResultKind= 5
  CXEval_Other* :enum_CXEvalResultKind= 6
  CXEval_UnExposed* :enum_CXEvalResultKind= 0
type CXEvalResultKind* = enum_CXEvalResultKind
## 
## Evaluation result of a cursor
type CXEvalResult* = pointer
## 
## If cursor is a statement declaration tries to evaluate the
## statement and if its variable, tries to evaluate its initializer,
## into its corresponding type.
## If it's an expression, tries to evaluate the expression.
proc clang_Cursor_Evaluate*(C :CXCursor) :CXEvalResult {.importc:"clang_Cursor_Evaluate", cdecl, dynlib:libclang.}
## 
## Returns the kind of the evaluated result.
proc clang_EvalResult_getKind*(E :CXEvalResult) :CXEvalResultKind {.importc:"clang_EvalResult_getKind", cdecl, dynlib:libclang.}
## 
## Returns the evaluation result as integer if the
## kind is Int.
proc clang_EvalResult_getAsInt*(E :CXEvalResult) :cint {.importc:"clang_EvalResult_getAsInt", cdecl, dynlib:libclang.}
## 
## Returns the evaluation result as a long long integer if the
## kind is Int. This prevents overflows that may happen if the result is
## returned with clang_EvalResult_getAsInt.
proc clang_EvalResult_getAsLongLong*(E :CXEvalResult) :clonglong {.importc:"clang_EvalResult_getAsLongLong", cdecl, dynlib:libclang.}
## 
## Returns a non-zero value if the kind is Int and the evaluation
## result resulted in an unsigned integer.
proc clang_EvalResult_isUnsignedInt*(E :CXEvalResult) :cuint {.importc:"clang_EvalResult_isUnsignedInt", cdecl, dynlib:libclang.}
## 
## Returns the evaluation result as an unsigned integer if
## the kind is Int and clang_EvalResult_isUnsignedInt is non-zero.
proc clang_EvalResult_getAsUnsigned*(E :CXEvalResult) :culonglong {.importc:"clang_EvalResult_getAsUnsigned", cdecl, dynlib:libclang.}
## 
## Returns the evaluation result as double if the
## kind is double.
proc clang_EvalResult_getAsDouble*(E :CXEvalResult) :cdouble {.importc:"clang_EvalResult_getAsDouble", cdecl, dynlib:libclang.}
## 
## Returns the evaluation result as a constant string if the
## kind is other than Int or float. User must not free this pointer,
## instead call clang_EvalResult_dispose on the CXEvalResult returned
## by clang_Cursor_Evaluate.
proc clang_EvalResult_getAsStr*(E :CXEvalResult) :cstring {.importc:"clang_EvalResult_getAsStr", cdecl, dynlib:libclang.}
## 
## Disposes the created Eval memory.
proc clang_EvalResult_dispose*(E :CXEvalResult) {.importc:"clang_EvalResult_dispose", cdecl, dynlib:libclang.}
## 
## A remapping of original source files and their translated files.
type CXRemapping* = pointer
## 
## Retrieve a remapping.
## 
## \param path the path that contains metadata about remappings.
## 
## \returns the requested remapping. This remapping must be freed
## via a call to clang_remap_dispose(). Can return NULL if an error occurred.
proc clang_getRemappings*(path :cstring) :CXRemapping {.importc:"clang_getRemappings", cdecl, dynlib:libclang.}
## 
## Retrieve a remapping.
## 
## \param filePaths pointer to an array of file paths containing remapping info.
## 
## \param numFiles number of file paths.
## 
## \returns the requested remapping. This remapping must be freed
## via a call to clang_remap_dispose(). Can return NULL if an error occurred.
proc clang_getRemappingsFromFileList*(filePaths :ptr cstring; numFiles :cuint) :CXRemapping {.importc:"clang_getRemappingsFromFileList", cdecl, dynlib:libclang.}
## 
## Determine the number of remappings.
proc clang_remap_getNumFiles*(a0 :CXRemapping) :cuint {.importc:"clang_remap_getNumFiles", cdecl, dynlib:libclang.}
## 
## Get the original and the associated filename from the remapping.
## 
## \param original If non-NULL, will be set to the original filename.
## 
## \param transformed If non-NULL, will be set to the filename that the original
## is associated with.
proc clang_remap_getFilenames*(a0 :CXRemapping; index :cuint; original :ptr CXString; transformed :ptr CXString) {.importc:"clang_remap_getFilenames", cdecl, dynlib:libclang.}
## 
## Dispose the remapping.
proc clang_remap_dispose*(a0 :CXRemapping) {.importc:"clang_remap_dispose", cdecl, dynlib:libclang.}
## \defgroup CINDEX_HIGH Higher level API functions
## 
## @{
type enum_CXVisitorResult* = cint
const
  CXVisit_Break* :enum_CXVisitorResult= 0
  CXVisit_Continue* :enum_CXVisitorResult= 1
type
  CXVisitorResult* = enum_CXVisitorResult
  ay_setCaseSensitivity"///
Set * {.the ca.} = object
    Overlay* :caseSen
    sitiv* :proc (cl :langcde; cl :importc"; le :ang_VirtualFi) :ecintdynliblibc {.Overl.}
  CXCursorAndRangeVisitor* = struct_CXCursorAndRangeVisitor
  enum_CXResult* = cint
const
  CXResult_Success* :enum_CXResult= 0
  CXResult_Invalid* :enum_CXResult= 1
  CXResult_VisitBreak* :enum_CXResult= 2
type CXResult* = enum_CXResult
## 
## Find references of a declaration in a specific file.
## 
## \param cursor pointing to a declaration or a reference of one.
## 
## \param file to search for references.
## 
## \param visitor callback that will receive pairs of CXCursor/CXSourceRange for
## each reference found.
## The CXSourceRange will point inside the file; if the reference is inside
## a macro (and not a macro argument) the CXSourceRange will be invalid.
## 
## \returns one of the CXResult enumerators.
proc clang_findReferencesInFile*(cursor :CXCursor; file :CXFile; visitor :CXCursorAndRangeVisitor) :CXResult {.importc:"clang_findReferencesInFile", cdecl, dynlib:libclang.}
## 
## Find #import/#include directives in a specific file.
## 
## \param TU translation unit containing the file to query.
## 
## \param file to search for #import/#include directives.
## 
## \param visitor callback that will receive pairs of CXCursor/CXSourceRange for
## each directive found.
## 
## \returns one of the CXResult enumerators.
proc clang_findIncludesInFile*(TU :CXTranslationUnit; file :CXFile; visitor :CXCursorAndRangeVisitor) :CXResult {.importc:"clang_findIncludesInFile", cdecl, dynlib:libclang.}
type
  struct_CXCursorAndRangeVisitorBlock* {.incompleteStruct.} = object
  priv_CXCursorAndRangeVisitorBlock* = struct_CXCursorAndRangeVisitorBlock
  CXCursorAndRangeVisitorBlock* = ptr struct_CXCursorAndRangeVisitorBlock
proc clang_findReferencesInFileWithBlock*(a0 :CXCursor; a1 :CXFile; a2 :CXCursorAndRangeVisitorBlock) :CXResult {.importc:"clang_findReferencesInFileWithBlock", cdecl, dynlib:libclang.}
proc clang_findIncludesInFileWithBlock*(a0 :CXTranslationUnit; a1 :CXFile; a2 :CXCursorAndRangeVisitorBlock) :CXResult {.importc:"clang_findIncludesInFileWithBlock", cdecl, dynlib:libclang.}
## 
## The client's data object that is associated with a CXFile.
type CXIdxClientFile* = pointer
## 
## The client's data object that is associated with a semantic entity.
type CXIdxClientEntity* = pointer
## 
## The client's data object that is associated with a semantic container
## of entities.
type CXIdxClientContainer* = pointer
## 
## The client's data object that is associated with an AST file (PCH
## or module).
type CXIdxClientASTFile* = pointer
## 
## Source location passed to index callbacks.
type ualFileO* {.verlay.} = object
  se sensi* :array[f, tivity ]
  or the C* :XVirt
## 
## Data for ppIncludedFile callback.
type  can be used to overr* {.ide th.} = object
   object* :.
The CX
  VirtualF* :ileOver
  lay * :`object`
   is case* :-sen
  sitive b* :y de
  fault, this
op* :tion
## 
## Data for IndexerCallbacks#importedASTFile.
type
  dicate an error.clang_Vi* {.rtualF.} = object
    e de* :fault.
    
\retu* :rns 0 fo
    r s* :uccess, 
    non-zero t* :o in
  enum_CXIdxEntityKind* = cint
const
  CXIdxEntity_Unexposed* :enum_CXIdxEntityKind= 0
  CXIdxEntity_Typedef* :enum_CXIdxEntityKind= 1
  CXIdxEntity_Function* :enum_CXIdxEntityKind= 2
  CXIdxEntity_Variable* :enum_CXIdxEntityKind= 3
  CXIdxEntity_Field* :enum_CXIdxEntityKind= 4
  CXIdxEntity_EnumConstant* :enum_CXIdxEntityKind= 5
  CXIdxEntity_ObjCClass* :enum_CXIdxEntityKind= 6
  CXIdxEntity_ObjCProtocol* :enum_CXIdxEntityKind= 7
  CXIdxEntity_ObjCCategory* :enum_CXIdxEntityKind= 8
  CXIdxEntity_ObjCInstanceMethod* :enum_CXIdxEntityKind= 9
  CXIdxEntity_ObjCClassMethod* :enum_CXIdxEntityKind= 10
  CXIdxEntity_ObjCProperty* :enum_CXIdxEntityKind= 11
  CXIdxEntity_ObjCIvar* :enum_CXIdxEntityKind= 12
  CXIdxEntity_Enum* :enum_CXIdxEntityKind= 13
  CXIdxEntity_Struct* :enum_CXIdxEntityKind= 14
  CXIdxEntity_Union* :enum_CXIdxEntityKind= 15
  CXIdxEntity_CXXClass* :enum_CXIdxEntityKind= 16
  CXIdxEntity_CXXNamespace* :enum_CXIdxEntityKind= 17
  CXIdxEntity_CXXNamespaceAlias* :enum_CXIdxEntityKind= 18
  CXIdxEntity_CXXStaticVariable* :enum_CXIdxEntityKind= 19
  CXIdxEntity_CXXStaticMethod* :enum_CXIdxEntityKind= 20
  CXIdxEntity_CXXInstanceMethod* :enum_CXIdxEntityKind= 21
  CXIdxEntity_CXXConstructor* :enum_CXIdxEntityKind= 22
  CXIdxEntity_CXXDestructor* :enum_CXIdxEntityKind= 23
  CXIdxEntity_CXXConversionFunction* :enum_CXIdxEntityKind= 24
  CXIdxEntity_CXXTypeAlias* :enum_CXIdxEntityKind= 25
  CXIdxEntity_CXXInterface* :enum_CXIdxEntityKind= 26
  CXIdxEntity_CXXConcept* :enum_CXIdxEntityKind= 27
type
  CXIdxEntityKind* = enum_CXIdxEntityKind
  enum_CXIdxEntityLanguage* = cint
const
  CXIdxEntityLang_None* :enum_CXIdxEntityLanguage= 0
  CXIdxEntityLang_C* :enum_CXIdxEntityLanguage= 1
  CXIdxEntityLang_ObjC* :enum_CXIdxEntityLanguage= 2
  CXIdxEntityLang_CXX* :enum_CXIdxEntityLanguage= 3
  CXIdxEntityLang_Swift* :enum_CXIdxEntityLanguage= 4
type CXIdxEntityLanguage* = enum_CXIdxEntityLanguage
## 
## Extra C++ template information for an entity. This can apply to:
## CXIdxEntity_Function
## CXIdxEntity_CXXClass
## CXIdxEntity_CXXStaticMethod
## CXIdxEntity_CXXInstanceMethod
## CXIdxEntity_CXXConstructor
## CXIdxEntity_CXXConversionFunction
## CXIdxEntity_CXXTypeAlias
type enum_CXIdxEntityCXXTemplateKind* = cint
const
  CXIdxEntity_NonTemplate* :enum_CXIdxEntityCXXTemplateKind= 0
  CXIdxEntity_Template* :enum_CXIdxEntityCXXTemplateKind= 1
  CXIdxEntity_TemplatePartialSpecialization* :enum_CXIdxEntityCXXTemplateKind= 2
  CXIdxEntity_TemplateSpecialization* :enum_CXIdxEntityCXXTemplateKind= 3
type
  CXIdxEntityCXXTemplateKind* = enum_CXIdxEntityCXXTemplateKind
  enum_CXIdxAttrKind* = cint
const
  CXIdxAttr_Unexposed* :enum_CXIdxAttrKind= 0
  CXIdxAttr_IBAction* :enum_CXIdxAttrKind= 1
  CXIdxAttr_IBOutlet* :enum_CXIdxAttrKind= 2
  CXIdxAttr_IBOutletCollection* :enum_CXIdxAttrKind= 3
type
  CXIdxAttrKind* = enum_CXIdxAttrKind
  tualFileOverl* {.ayopti.} = object
    ileO* :verlay_writeT
    oBuffe* :rCXError
    Cod* :ea0CXVir
  ject to a char * {.buffer.} = object
    onsc* :uintout_buffer_
    ptrcstringou* :t_buffer_sizecuintdynlibli
    bcla* :ngcdeclimportc"clan
    g_Vi* :rtualFi
    leO* :verlay_
    writeT* :oBuffer"
    ///
Write * :ptr ptr out the CXVir
    tualFileOverl* :ay ob
  ons is reserved, a* {.lways .} = object
    .

\pa* :ram opti
  d be
disposed using clang_free(* {.).
\pa.} = object
    pass 0.
* :ptr \param out_bu
    ffer_ptr * :ptr pointer to rece
    ive the buf* :fer poin
    ter, whi* :ch shoul
  enum_CXIdxDeclInfoFlags* = cint
const CXIdxDeclFlag_Skipped* :enum_CXIdxDeclInfoFlags= 1
type
  CXIdxDeclInfoFlags* = enum_CXIdxDeclInfoFlags
  clang_ModuleM* {.apDesc.} = object
    ram out_bu* :ptr ffer_size point
    er to * :receive 
    the* : buffer 
    size.
\returns 0 * :ptr for success, non-z
    ero to indicate * :ptr an error.clang_fre
    ebufferpointerd* :ynli
    blibclangcde* :clim
    portc"clang* :_fre
    e"///
free memo* :ptr ry allocated by li
    bclang, su* :ch a
    s the buff* :ptr ptr er returned b
    y
CXVirtualFi* :leOve
    rlay(* :) or 
  enum_CXIdxObjCContainerKind* = cint
const
  CXIdxObjCContainer_ForwardRef* :enum_CXIdxObjCContainerKind= 0
  CXIdxObjCContainer_Interface* :enum_CXIdxObjCContainerKind= 1
  CXIdxObjCContainer_Implementation* :enum_CXIdxObjCContainerKind= 2
type
  CXIdxObjCContainerKind* = enum_CXIdxObjCContainerKind
  ointer to free.clang_Virtu* {.alFile.} = object
    riptor_w* :ptr riteToBuffer(
    ).

* :\param buffer memory p
  ibclangcdeclimport* {.c"clan.} = object
    Over* :ptr lay_disposea0CX
    Virtua* :lFileOve
    rla* :ydynlibl
  tualFileOverlay object.s* {.truct_.} = object
    g_Virtua* :ptr lFileOverlay_di
    spose"* :///
Disp
    ose* : a CXVir
  apDescriptorImplstruct_CXMod* {.uleMap.} = object
    CXModuleM* :ptr ptr apDescriptorImplincomple
    teStructCXMo* :duleM
  riptorImplCXModuleMapDescr* {.iptorc.} = object
    DescriptorImp* :ptr l///
Object encapsulating 
    informati* :ptr on about a module.
    modulemap* :ptr  file.struct_CXModuleMapDesc
  a CXModuleMapDescriptor o* {.bject..} = object
    lang_ModuleMa* :ptr pDescriptor_createCXModule
    MapDescri* :ptr ptoroptionscuin
    tdynliblibc* :langcdec
    limportc* :"clang_M
    oduleMapD* :ptr escriptor_create"///
Create 
  aram options is reserved,* {. alway.} = object
    
Must be* :ptr  disposed wit
    h clan* :ptr g_ModuleMapDesc
    riptor* :ptr _dispose().

\p
  CXErrorCodea0CXModule* {.MapDes.} = object
    s pass 0* :ptr .clang_Module
    MapDe* :ptr ptr scriptor_setFramew
    orkModul* :eName
## 
## Data for IndexerCallbacks#indexEntityReference.
## 
## This may be deprecated in a future version as this duplicates
## the CXSymbolRole_Implicit bit in CXSymbolRole.
type enum_CXIdxEntityRefKind* = cint
const
  CXIdxEntityRef_Direct* :enum_CXIdxEntityRefKind= 1
  CXIdxEntityRef_Implicit* :enum_CXIdxEntityRefKind= 2
type CXIdxEntityRefKind* = enum_CXIdxEntityRefKind
## 
## Roles that are attributed to symbol occurrences.
## 
## Internal: this currently mirrors low 9 bits of clang::index::SymbolRole with
## higher bits zeroed. These high bits may be exposed in the future.
type enum_CXSymbolRole* = cint
const
  CXSymbolRole_None* :enum_CXSymbolRole= 0
  CXSymbolRole_Declaration* :enum_CXSymbolRole= 1
  CXSymbolRole_Definition* :enum_CXSymbolRole= 2
  CXSymbolRole_Reference* :enum_CXSymbolRole= 4
  CXSymbolRole_Read* :enum_CXSymbolRole= 8
  CXSymbolRole_Write* :enum_CXSymbolRole= 16
  CXSymbolRole_Call* :enum_CXSymbolRole= 32
  CXSymbolRole_Dynamic* :enum_CXSymbolRole= 64
  CXSymbolRole_AddressOf* :enum_CXSymbolRole= 128
  CXSymbolRole_Implicit* :enum_CXSymbolRole= 256
type CXSymbolRole* = enum_CXSymbolRole
## 
## Data for IndexerCallbacks#indexEntityReference.
type ulemap describes.
* {.\retur.} = object
  crip* :tornamecstringdynl
  iblibc* :langcdec
  lim* :portc"cl
  ang_ModuleMapDes* :ptr criptor_setFram
  eworkModuleN* :ptr ame"///
Sets th
  e framewo* :ptr rk module name tha
  t th* :e module.mod
## 
## A group of callbacks used by #clang_indexSourceFile and
## #clang_indexTranslationUnit.
type ModuleMapDescrip* {.tor_wr.} = object
  ns 0 for s* :proc ( t :ss, non-zero; at :o indic) :ucce {.e an .}
  error.clan* :proc (es :g_ModuleMapD; el :criptor_setUmbr; rC :laHeade) {.XErro.}
  rCodea0CXModule* :proc (li :mecstringdyn; an :blibcl; mp :gcdecli) :MapDescriptorna {.ortc".}
  clang_ModuleMa* :proc (er :UmbrellaHead; a  :ptr "///
Sets the umbrell) :pDescriptor_set {.heade.}
  r name that the* :proc (re :describes.
\; -z :ptr turns 0 for success, non) : module.modulemap  {.ero t.}
  o indicate an error.cl* :proc (uf :tor_writeToB; ro :ferCXEr) :ang_ModuleMapDescrip {.rCode.}
  a0CXModuleMapDes* :proc (ns :criptoroptio; er :ptr cuintout_buff) {._ptrc.}
  stringout_buffer_siz* :proc (li :ecuintdynlib; "c :ptr bclangcdeclimportc) {.lang_.}
proc clang_index_isEntityObjCContainerKind*(a0 :CXIdxEntityKind) :cint {.importc:"clang_index_isEntityObjCContainerKind", cdecl, dynlib:libclang.}
proc clang_index_getObjCContainerDeclInfo*(a0 :ptr CXIdxDeclInfo) :ptr CXIdxObjCContainerDeclInfo {.importc:"clang_index_getObjCContainerDeclInfo", cdecl, dynlib:libclang.}
proc clang_index_getObjCInterfaceDeclInfo*(a0 :ptr CXIdxDeclInfo) :ptr CXIdxObjCInterfaceDeclInfo {.importc:"clang_index_getObjCInterfaceDeclInfo", cdecl, dynlib:libclang.}
proc clang_index_getObjCCategoryDeclInfo*(a0 :ptr CXIdxDeclInfo) :ptr CXIdxObjCCategoryDeclInfo {.importc:"clang_index_getObjCCategoryDeclInfo", cdecl, dynlib:libclang.}
proc clang_index_getObjCProtocolRefListInfo*(a0 :ptr CXIdxDeclInfo) :ptr CXIdxObjCProtocolRefListInfo {.importc:"clang_index_getObjCProtocolRefListInfo", cdecl, dynlib:libclang.}
proc clang_index_getObjCPropertyDeclInfo*(a0 :ptr CXIdxDeclInfo) :ptr CXIdxObjCPropertyDeclInfo {.importc:"clang_index_getObjCPropertyDeclInfo", cdecl, dynlib:libclang.}
proc clang_index_getIBOutletCollectionAttrInfo*(a0 :ptr CXIdxAttrInfo) :ptr CXIdxIBOutletCollectionAttrInfo {.importc:"clang_index_getIBOutletCollectionAttrInfo", cdecl, dynlib:libclang.}
proc clang_index_getCXXClassDeclInfo*(a0 :ptr CXIdxDeclInfo) :ptr CXIdxCXXClassDeclInfo {.importc:"clang_index_getCXXClassDeclInfo", cdecl, dynlib:libclang.}
## 
## For retrieving a custom CXIdxClientContainer attached to a
## container.
proc clang_index_getClientContainer*(a0 :ptr CXIdxContainerInfo) :CXIdxClientContainer {.importc:"clang_index_getClientContainer", cdecl, dynlib:libclang.}
## 
## For setting a custom CXIdxClientContainer attached to a
## container.
proc clang_index_setClientContainer*(a0 :ptr CXIdxContainerInfo; a1 :CXIdxClientContainer) {.importc:"clang_index_setClientContainer", cdecl, dynlib:libclang.}
## 
## For retrieving a custom CXIdxClientEntity attached to an entity.
proc clang_index_getClientEntity*(a0 :ptr CXIdxEntityInfo) :CXIdxClientEntity {.importc:"clang_index_getClientEntity", cdecl, dynlib:libclang.}
## 
## For setting a custom CXIdxClientEntity attached to an entity.
proc clang_index_setClientEntity*(a0 :ptr CXIdxEntityInfo; a1 :CXIdxClientEntity) {.importc:"clang_index_setClientEntity", cdecl, dynlib:libclang.}
## 
## An indexing action/session, to be applied to one or multiple
## translation units.
type CXIndexAction* = pointer
## 
## An indexing action/session, to be applied to one or multiple
## translation units.
## 
## \param CIdx The index object with which the index action will be associated.
proc clang_IndexAction_create*(CIdx :CXIndex) :CXIndexAction {.importc:"clang_IndexAction_create", cdecl, dynlib:libclang.}
## 
## Destroy the given index action.
## 
## The index action must not be destroyed until all of the translation units
## created within that index action have been destroyed.
proc clang_IndexAction_dispose*(a0 :CXIndexAction) {.importc:"clang_IndexAction_dispose", cdecl, dynlib:libclang.}
type enum_CXIndexOptFlags* = cint
const
  CXIndexOpt_None* :enum_CXIndexOptFlags= 0
  CXIndexOpt_SuppressRedundantRefs* :enum_CXIndexOptFlags= 1
  CXIndexOpt_IndexFunctionLocalSymbols* :enum_CXIndexOptFlags= 2
  CXIndexOpt_IndexImplicitTemplateInstantiations* :enum_CXIndexOptFlags= 4
  CXIndexOpt_SuppressWarnings* :enum_CXIndexOptFlags= 8
  CXIndexOpt_SkipParsedBodiesInSession* :enum_CXIndexOptFlags= 16
type CXIndexOptFlags* = enum_CXIndexOptFlags
## 
## Index the given source file and the translation unit corresponding
## to that file via callbacks implemented through #IndexerCallbacks.
## 
## \param client_data pointer data supplied by the client, which will
## be passed to the invoked callbacks.
## 
## \param index_callbacks Pointer to indexing callbacks that the client
## implements.
## 
## \param index_callbacks_size Size of #IndexerCallbacks structure that gets
## passed in index_callbacks.
## 
## \param index_options A bitmask of options that affects how indexing is
## performed. This should be a bitwise OR of the CXIndexOpt_XXX flags.
## 
## \param[out] out_TU pointer to store a CXTranslationUnit that can be
## reused after indexing is finished. Set to NULL if you do not require it.
## 
## \returns 0 on success or if there were errors from which the compiler could
## recover.  If there is a failure from which there is no recovery, returns
## a non-zero CXErrorCode.
## 
## The rest of the parameters are the same as #clang_parseTranslationUnit.
proc clang_indexSourceFile*(a0 :CXIndexAction; client_data :CXClientData; index_callbacks :ptr IndexerCallbacks; index_callbacks_size :cuint; index_options :cuint; source_filename :cstring; command_line_args :ptr cstring; num_command_line_args :cint; unsaved_files :ptr struct_CXUnsavedFile; num_unsaved_files :cuint; out_TU :ptr CXTranslationUnit; TU_options :cuint) :cint {.importc:"clang_indexSourceFile", cdecl, dynlib:libclang.}
## 
## Same as clang_indexSourceFile but requires a full command line
## for command_line_args including argv[0]. This is useful if the standard
## library paths are relative to the binary.
proc clang_indexSourceFileFullArgv*(a0 :CXIndexAction; client_data :CXClientData; index_callbacks :ptr IndexerCallbacks; index_callbacks_size :cuint; index_options :cuint; source_filename :cstring; command_line_args :ptr cstring; num_command_line_args :cint; unsaved_files :ptr struct_CXUnsavedFile; num_unsaved_files :cuint; out_TU :ptr CXTranslationUnit; TU_options :cuint) :cint {.importc:"clang_indexSourceFileFullArgv", cdecl, dynlib:libclang.}
## 
## Index the given translation unit via callbacks implemented through
## #IndexerCallbacks.
## 
## The order of callback invocations is not guaranteed to be the same as
## when indexing a source file. The high level order will be:
## 
##   -Preprocessor callbacks invocations
##   -Declaration/reference callbacks invocations
##   -Diagnostic callback invocations
## 
## The parameters are the same as #clang_indexSourceFile.
## 
## \returns If there is a failure from which there is no recovery, returns
## non-zero, otherwise returns 0.
proc clang_indexTranslationUnit*(a0 :CXIndexAction; client_data :CXClientData; index_callbacks :ptr IndexerCallbacks; index_callbacks_size :cuint; index_options :cuint; a5 :CXTranslationUnit) :cint {.importc:"clang_indexTranslationUnit", cdecl, dynlib:libclang.}
## 
## Retrieve the CXIdxFile, file, line, column, and offset represented by
## the given CXIdxLoc.
## 
## If the location refers into a macro expansion, retrieves the
## location of the macro expansion and if it refers into a macro argument
## retrieves the location of the argument.
proc clang_indexLoc_getFileLocation*(loc :CXIdxLoc; indexFile :ptr CXIdxClientFile; file :ptr CXFile; line :ptr cuint; column :ptr cuint; offset :ptr cuint) {.importc:"clang_indexLoc_getFileLocation", cdecl, dynlib:libclang.}
## 
## Retrieve the CXSourceLocation represented by the given CXIdxLoc.
proc clang_indexLoc_getCXSourceLocation*(loc :CXIdxLoc) :CXSourceLocation {.importc:"clang_indexLoc_getCXSourceLocation", cdecl, dynlib:libclang.}
## 
## Visitor invoked for each field found by a traversal.
## 
## This visitor function will be invoked for each field found by
## clang_Type_visitFields. Its first argument is the cursor being
## visited, its second argument is the client data provided to
## clang_Type_visitFields.
## 
## The visitor should return one of the CXVisitorResult values
## to direct clang_Type_visitFields.
type CXFieldVisitor* = proc (a0 :CXCursor; a1 :CXClientData) :CXVisitorResult {.cdecl.}
## 
## Visit the fields of a particular type.
## 
## This function visits all the direct fields of the given cursor,
## invoking the given visitor function with the cursors of each
## visited field. The traversal may be ended prematurely, if
## the visitor returns CXFieldVisit_Break.
## 
## \param T the record type whose field may be visited.
## 
## \param visitor the visitor function that will be invoked for each
## field of T.
## 
## \param client_data pointer data supplied by the client, which will
## be passed to the visitor each time it is invoked.
## 
## \returns a non-zero value if the traversal was terminated
## prematurely by the visitor returning CXFieldVisit_Break.
proc clang_Type_visitFields*(T :CXType; visitor :CXFieldVisitor; client_data :CXClientData) :cuint {.importc:"clang_Type_visitFields", cdecl, dynlib:libclang.}
## 
## Describes the kind of binary operators.
type enum_CXBinaryOperatorKind* = cint
const
  CXBinaryOperator_Invalid* :enum_CXBinaryOperatorKind= 0
  CXBinaryOperator_PtrMemD* :enum_CXBinaryOperatorKind= 1
  CXBinaryOperator_PtrMemI* :enum_CXBinaryOperatorKind= 2
  CXBinaryOperator_Mul* :enum_CXBinaryOperatorKind= 3
  CXBinaryOperator_Div* :enum_CXBinaryOperatorKind= 4
  CXBinaryOperator_Rem* :enum_CXBinaryOperatorKind= 5
  CXBinaryOperator_Add* :enum_CXBinaryOperatorKind= 6
  CXBinaryOperator_Sub* :enum_CXBinaryOperatorKind= 7
  CXBinaryOperator_Shl* :enum_CXBinaryOperatorKind= 8
  CXBinaryOperator_Shr* :enum_CXBinaryOperatorKind= 9
  CXBinaryOperator_Cmp* :enum_CXBinaryOperatorKind= 10
  CXBinaryOperator_LT* :enum_CXBinaryOperatorKind= 11
  CXBinaryOperator_GT* :enum_CXBinaryOperatorKind= 12
  CXBinaryOperator_LE* :enum_CXBinaryOperatorKind= 13
  CXBinaryOperator_GE* :enum_CXBinaryOperatorKind= 14
  CXBinaryOperator_EQ* :enum_CXBinaryOperatorKind= 15
  CXBinaryOperator_NE* :enum_CXBinaryOperatorKind= 16
  CXBinaryOperator_And* :enum_CXBinaryOperatorKind= 17
  CXBinaryOperator_Xor* :enum_CXBinaryOperatorKind= 18
  CXBinaryOperator_Or* :enum_CXBinaryOperatorKind= 19
  CXBinaryOperator_LAnd* :enum_CXBinaryOperatorKind= 20
  CXBinaryOperator_LOr* :enum_CXBinaryOperatorKind= 21
  CXBinaryOperator_Assign* :enum_CXBinaryOperatorKind= 22
  CXBinaryOperator_MulAssign* :enum_CXBinaryOperatorKind= 23
  CXBinaryOperator_DivAssign* :enum_CXBinaryOperatorKind= 24
  CXBinaryOperator_RemAssign* :enum_CXBinaryOperatorKind= 25
  CXBinaryOperator_AddAssign* :enum_CXBinaryOperatorKind= 26
  CXBinaryOperator_SubAssign* :enum_CXBinaryOperatorKind= 27
  CXBinaryOperator_ShlAssign* :enum_CXBinaryOperatorKind= 28
  CXBinaryOperator_ShrAssign* :enum_CXBinaryOperatorKind= 29
  CXBinaryOperator_AndAssign* :enum_CXBinaryOperatorKind= 30
  CXBinaryOperator_XorAssign* :enum_CXBinaryOperatorKind= 31
  CXBinaryOperator_OrAssign* :enum_CXBinaryOperatorKind= 32
  CXBinaryOperator_Comma* :enum_CXBinaryOperatorKind= 33
type CXBinaryOperatorKind* = enum_CXBinaryOperatorKind
## 
## Retrieve the spelling of a given CXBinaryOperatorKind.
proc clang_getBinaryOperatorKindSpelling*(kind :CXBinaryOperatorKind) :CXString {.importc:"clang_getBinaryOperatorKindSpelling", cdecl, dynlib:libclang.}
## 
## Retrieve the binary operator kind of this cursor.
## 
## If this cursor is not a binary operator then returns Invalid.
proc clang_getCursorBinaryOperatorKind*(cursor :CXCursor) :CXBinaryOperatorKind {.importc:"clang_getCursorBinaryOperatorKind", cdecl, dynlib:libclang.}
## 
## Describes the kind of unary operators.
type enum_CXUnaryOperatorKind* = cint
const
  CXUnaryOperator_Invalid* :enum_CXUnaryOperatorKind= 0
  CXUnaryOperator_PostInc* :enum_CXUnaryOperatorKind= 1
  CXUnaryOperator_PostDec* :enum_CXUnaryOperatorKind= 2
  CXUnaryOperator_PreInc* :enum_CXUnaryOperatorKind= 3
  CXUnaryOperator_PreDec* :enum_CXUnaryOperatorKind= 4
  CXUnaryOperator_AddrOf* :enum_CXUnaryOperatorKind= 5
  CXUnaryOperator_Deref* :enum_CXUnaryOperatorKind= 6
  CXUnaryOperator_Plus* :enum_CXUnaryOperatorKind= 7
  CXUnaryOperator_Minus* :enum_CXUnaryOperatorKind= 8
  CXUnaryOperator_Not* :enum_CXUnaryOperatorKind= 9
  CXUnaryOperator_LNot* :enum_CXUnaryOperatorKind= 10
  CXUnaryOperator_Real* :enum_CXUnaryOperatorKind= 11
  CXUnaryOperator_Imag* :enum_CXUnaryOperatorKind= 12
  CXUnaryOperator_Extension* :enum_CXUnaryOperatorKind= 13
  CXUnaryOperator_Coawait* :enum_CXUnaryOperatorKind= 14
type CXUnaryOperatorKind* = enum_CXUnaryOperatorKind
## 
## Retrieve the spelling of a given CXUnaryOperatorKind.
proc clang_getUnaryOperatorKindSpelling*(kind :CXUnaryOperatorKind) :CXString {.importc:"clang_getUnaryOperatorKindSpelling", cdecl, dynlib:libclang.}
## 
## Retrieve the unary operator kind of this cursor.
## 
## If this cursor is not a unary operator then returns Invalid.
proc clang_getCursorUnaryOperatorKind*(cursor :CXCursor) :CXUnaryOperatorKind {.importc:"clang_getCursorUnaryOperatorKind", cdecl, dynlib:libclang.}
## 
## A compilation database holds all information used to compile files in a
## project. For each file in the database, it can be queried for the working
## directory or the command line used for the compiler invocation.
## 
## Must be freed by clang_CompilationDatabase_dispose
type CXCompilationDatabase* = pointer
## 
## Contains the results of a search in the compilation database
## 
## When searching for the compile command for a file, the compilation db can
## return several commands, as the file may have been compiled with
## different options in different places of the project. This choice of compile
## commands is wrapped in this opaque data structure. It must be freed by
## clang_CompileCommands_dispose.
type CXCompileCommands* = pointer
## 
## Represents the command line invocation to compile a specific file.
type CXCompileCommand* = pointer
## 
## Error codes for Compilation Database
type enum_CXCompilationDatabase_Error* = cint
const
  CXCompilationDatabase_NoError* :enum_CXCompilationDatabase_Error= 0
  CXCompilationDatabase_CanNotLoadDatabase* :enum_CXCompilationDatabase_Error= 1
type CXCompilationDatabase_Error* = enum_CXCompilationDatabase_Error
## 
## Creates a compilation database from the database found in directory
## buildDir. For example, CMake can output a compile_commands.json which can
## be used to build the database.
## 
## It must be freed by clang_CompilationDatabase_dispose.
proc clang_CompilationDatabase_fromDirectory*(BuildDir :cstring; ErrorCode :ptr CXCompilationDatabase_Error) :CXCompilationDatabase {.importc:"clang_CompilationDatabase_fromDirectory", cdecl, dynlib:libclang.}
## 
## Free the given compilation database
proc clang_CompilationDatabase_dispose*(a0 :CXCompilationDatabase) {.importc:"clang_CompilationDatabase_dispose", cdecl, dynlib:libclang.}
## 
## Find the compile commands used for a file. The compile commands
## must be freed by clang_CompileCommands_dispose.
proc clang_CompilationDatabase_getCompileCommands*(a0 :CXCompilationDatabase; CompleteFileName :cstring) :CXCompileCommands {.importc:"clang_CompilationDatabase_getCompileCommands", cdecl, dynlib:libclang.}
## 
## Get all the compile commands in the given compilation database.
proc clang_CompilationDatabase_getAllCompileCommands*(a0 :CXCompilationDatabase) :CXCompileCommands {.importc:"clang_CompilationDatabase_getAllCompileCommands", cdecl, dynlib:libclang.}
## 
## Free the given CompileCommands
proc clang_CompileCommands_dispose*(a0 :CXCompileCommands) {.importc:"clang_CompileCommands_dispose", cdecl, dynlib:libclang.}
## 
## Get the number of CompileCommand we have for a file
proc clang_CompileCommands_getSize*(a0 :CXCompileCommands) :cuint {.importc:"clang_CompileCommands_getSize", cdecl, dynlib:libclang.}
## 
## Get the I'th CompileCommand for a file
## 
## Note : 0 <= i < clang_CompileCommands_getSize(CXCompileCommands)
proc clang_CompileCommands_getCommand*(a0 :CXCompileCommands; I :cuint) :CXCompileCommand {.importc:"clang_CompileCommands_getCommand", cdecl, dynlib:libclang.}
## 
## Get the working directory where the CompileCommand was executed from
proc clang_CompileCommand_getDirectory*(a0 :CXCompileCommand) :CXString {.importc:"clang_CompileCommand_getDirectory", cdecl, dynlib:libclang.}
## 
## Get the filename associated with the CompileCommand.
proc clang_CompileCommand_getFilename*(a0 :CXCompileCommand) :CXString {.importc:"clang_CompileCommand_getFilename", cdecl, dynlib:libclang.}
## 
## Get the number of arguments in the compiler invocation.
proc clang_CompileCommand_getNumArgs*(a0 :CXCompileCommand) :cuint {.importc:"clang_CompileCommand_getNumArgs", cdecl, dynlib:libclang.}
## 
## Get the I'th argument value in the compiler invocations
## 
## Invariant :
##  - argument 0 is the compiler executable
proc clang_CompileCommand_getArg*(a0 :CXCompileCommand; I :cuint) :CXString {.importc:"clang_CompileCommand_getArg", cdecl, dynlib:libclang.}
## 
## Get the number of source mappings for the compiler invocation.
proc clang_CompileCommand_getNumMappedSources*(a0 :CXCompileCommand) :cuint {.importc:"clang_CompileCommand_getNumMappedSources", cdecl, dynlib:libclang.}
## 
## Get the I'th mapped source path for the compiler invocation.
proc clang_CompileCommand_getMappedSourcePath*(a0 :CXCompileCommand; I :cuint) :CXString {.importc:"clang_CompileCommand_getMappedSourcePath", cdecl, dynlib:libclang.}
## 
## Get the I'th mapped source content for the compiler invocation.
proc clang_CompileCommand_getMappedSourceContent*(a0 :CXCompileCommand; I :cuint) :CXString {.importc:"clang_CompileCommand_getMappedSourceContent", cdecl, dynlib:libclang.}
## 
## Installs error handler that prints error message to stderr and calls abort().
## Replaces currently installed error handler (if any).
proc clang_install_aborting_llvm_fatal_error_handler*() {.importc:"clang_install_aborting_llvm_fatal_error_handler", cdecl, dynlib:libclang.}
## 
## Removes currently installed error handler (if any).
## If no error handler is intalled, the default strategy is to print error
## message to stderr and call exit(1).
proc clang_uninstall_llvm_fatal_error_handler*() {.importc:"clang_uninstall_llvm_fatal_error_handler", cdecl, dynlib:libclang.}
## 
## A parsed comment.
type CXComment* {.bycopy.} = object
  ASTNode* :pointer
  TranslationUnit* :CXTranslationUnit
## 
## Given a cursor that represents a documentable entity (e.g.,
## declaration), return the associated parsed comment as a
## CXComment_FullComment AST node.
proc clang_Cursor_getParsedComment*(C :CXCursor) :CXComment {.importc:"clang_Cursor_getParsedComment", cdecl, dynlib:libclang.}
## 
## Describes the type of the comment AST node (CXComment).  A comment
## node can be considered block content (e. g., paragraph), inline content
## (plain text) or neither (the root AST node).
type enum_CXCommentKind* = cint
const
  CXComment_Null* :enum_CXCommentKind= 0
  CXComment_Text* :enum_CXCommentKind= 1
  CXComment_InlineCommand* :enum_CXCommentKind= 2
  CXComment_HTMLStartTag* :enum_CXCommentKind= 3
  CXComment_HTMLEndTag* :enum_CXCommentKind= 4
  CXComment_Paragraph* :enum_CXCommentKind= 5
  CXComment_BlockCommand* :enum_CXCommentKind= 6
  CXComment_ParamCommand* :enum_CXCommentKind= 7
  CXComment_TParamCommand* :enum_CXCommentKind= 8
  CXComment_VerbatimBlockCommand* :enum_CXCommentKind= 9
  CXComment_VerbatimBlockLine* :enum_CXCommentKind= 10
  CXComment_VerbatimLine* :enum_CXCommentKind= 11
  CXComment_FullComment* :enum_CXCommentKind= 12
type CXCommentKind* = enum_CXCommentKind
## 
## The most appropriate rendering mode for an inline command, chosen on
## command semantics in Doxygen.
type enum_CXCommentInlineCommandRenderKind* = cint
const
  CXCommentInlineCommandRenderKind_Normal* :enum_CXCommentInlineCommandRenderKind= 0
  CXCommentInlineCommandRenderKind_Bold* :enum_CXCommentInlineCommandRenderKind= 1
  CXCommentInlineCommandRenderKind_Monospaced* :enum_CXCommentInlineCommandRenderKind= 2
  CXCommentInlineCommandRenderKind_Emphasized* :enum_CXCommentInlineCommandRenderKind= 3
  CXCommentInlineCommandRenderKind_Anchor* :enum_CXCommentInlineCommandRenderKind= 4
type CXCommentInlineCommandRenderKind* = enum_CXCommentInlineCommandRenderKind
## 
## Describes parameter passing direction for \\param or \\arg command.
type enum_CXCommentParamPassDirection* = cint
const
  CXCommentParamPassDirection_In* :enum_CXCommentParamPassDirection= 0
  CXCommentParamPassDirection_Out* :enum_CXCommentParamPassDirection= 1
  CXCommentParamPassDirection_InOut* :enum_CXCommentParamPassDirection= 2
type CXCommentParamPassDirection* = enum_CXCommentParamPassDirection
## 
## \param Comment AST node of any kind.
## 
## \returns the type of the AST node.
proc clang_Comment_getKind*(Comment :CXComment) :CXCommentKind {.importc:"clang_Comment_getKind", cdecl, dynlib:libclang.}
## 
## \param Comment AST node of any kind.
## 
## \returns number of children of the AST node.
proc clang_Comment_getNumChildren*(Comment :CXComment) :cuint {.importc:"clang_Comment_getNumChildren", cdecl, dynlib:libclang.}
## 
## \param Comment AST node of any kind.
## 
## \param ChildIdx child index (zero-based).
## 
## \returns the specified child of the AST node.
proc clang_Comment_getChild*(Comment :CXComment; ChildIdx :cuint) :CXComment {.importc:"clang_Comment_getChild", cdecl, dynlib:libclang.}
## 
## A CXComment_Paragraph node is considered whitespace if it contains
## only CXComment_Text nodes that are empty or whitespace.
## 
## Other AST nodes (except CXComment_Paragraph and CXComment_Text) are
## never considered whitespace.
## 
## \returns non-zero if Comment is whitespace.
proc clang_Comment_isWhitespace*(Comment :CXComment) :cuint {.importc:"clang_Comment_isWhitespace", cdecl, dynlib:libclang.}
## 
## \returns non-zero if Comment is inline content and has a newline
## immediately following it in the comment text.  Newlines between paragraphs
## do not count.
proc clang_InlineContentComment_hasTrailingNewline*(Comment :CXComment) :cuint {.importc:"clang_InlineContentComment_hasTrailingNewline", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_Text AST node.
## 
## \returns text contained in the AST node.
proc clang_TextComment_getText*(Comment :CXComment) :CXString {.importc:"clang_TextComment_getText", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_InlineCommand AST node.
## 
## \returns name of the inline command.
proc clang_InlineCommandComment_getCommandName*(Comment :CXComment) :CXString {.importc:"clang_InlineCommandComment_getCommandName", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_InlineCommand AST node.
## 
## \returns the most appropriate rendering mode, chosen on command
## semantics in Doxygen.
proc clang_InlineCommandComment_getRenderKind*(Comment :CXComment) :CXCommentInlineCommandRenderKind {.importc:"clang_InlineCommandComment_getRenderKind", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_InlineCommand AST node.
## 
## \returns number of command arguments.
proc clang_InlineCommandComment_getNumArgs*(Comment :CXComment) :cuint {.importc:"clang_InlineCommandComment_getNumArgs", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_InlineCommand AST node.
## 
## \param ArgIdx argument index (zero-based).
## 
## \returns text of the specified argument.
proc clang_InlineCommandComment_getArgText*(Comment :CXComment; ArgIdx :cuint) :CXString {.importc:"clang_InlineCommandComment_getArgText", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_HTMLStartTag or CXComment_HTMLEndTag AST
## node.
## 
## \returns HTML tag name.
proc clang_HTMLTagComment_getTagName*(Comment :CXComment) :CXString {.importc:"clang_HTMLTagComment_getTagName", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_HTMLStartTag AST node.
## 
## \returns non-zero if tag is self-closing (for example, &lt;br /&gt;).
proc clang_HTMLStartTagComment_isSelfClosing*(Comment :CXComment) :cuint {.importc:"clang_HTMLStartTagComment_isSelfClosing", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_HTMLStartTag AST node.
## 
## \returns number of attributes (name-value pairs) attached to the start tag.
proc clang_HTMLStartTag_getNumAttrs*(Comment :CXComment) :cuint {.importc:"clang_HTMLStartTag_getNumAttrs", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_HTMLStartTag AST node.
## 
## \param AttrIdx attribute index (zero-based).
## 
## \returns name of the specified attribute.
proc clang_HTMLStartTag_getAttrName*(Comment :CXComment; AttrIdx :cuint) :CXString {.importc:"clang_HTMLStartTag_getAttrName", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_HTMLStartTag AST node.
## 
## \param AttrIdx attribute index (zero-based).
## 
## \returns value of the specified attribute.
proc clang_HTMLStartTag_getAttrValue*(Comment :CXComment; AttrIdx :cuint) :CXString {.importc:"clang_HTMLStartTag_getAttrValue", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_BlockCommand AST node.
## 
## \returns name of the block command.
proc clang_BlockCommandComment_getCommandName*(Comment :CXComment) :CXString {.importc:"clang_BlockCommandComment_getCommandName", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_BlockCommand AST node.
## 
## \returns number of word-like arguments.
proc clang_BlockCommandComment_getNumArgs*(Comment :CXComment) :cuint {.importc:"clang_BlockCommandComment_getNumArgs", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_BlockCommand AST node.
## 
## \param ArgIdx argument index (zero-based).
## 
## \returns text of the specified word-like argument.
proc clang_BlockCommandComment_getArgText*(Comment :CXComment; ArgIdx :cuint) :CXString {.importc:"clang_BlockCommandComment_getArgText", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_BlockCommand or
## CXComment_VerbatimBlockCommand AST node.
## 
## \returns paragraph argument of the block command.
proc clang_BlockCommandComment_getParagraph*(Comment :CXComment) :CXComment {.importc:"clang_BlockCommandComment_getParagraph", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_ParamCommand AST node.
## 
## \returns parameter name.
proc clang_ParamCommandComment_getParamName*(Comment :CXComment) :CXString {.importc:"clang_ParamCommandComment_getParamName", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_ParamCommand AST node.
## 
## \returns non-zero if the parameter that this AST node represents was found
## in the function prototype and clang_ParamCommandComment_getParamIndex
## function will return a meaningful value.
proc clang_ParamCommandComment_isParamIndexValid*(Comment :CXComment) :cuint {.importc:"clang_ParamCommandComment_isParamIndexValid", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_ParamCommand AST node.
## 
## \returns zero-based parameter index in function prototype.
proc clang_ParamCommandComment_getParamIndex*(Comment :CXComment) :cuint {.importc:"clang_ParamCommandComment_getParamIndex", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_ParamCommand AST node.
## 
## \returns non-zero if parameter passing direction was specified explicitly in
## the comment.
proc clang_ParamCommandComment_isDirectionExplicit*(Comment :CXComment) :cuint {.importc:"clang_ParamCommandComment_isDirectionExplicit", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_ParamCommand AST node.
## 
## \returns parameter passing direction.
proc clang_ParamCommandComment_getDirection*(Comment :CXComment) :CXCommentParamPassDirection {.importc:"clang_ParamCommandComment_getDirection", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_TParamCommand AST node.
## 
## \returns template parameter name.
proc clang_TParamCommandComment_getParamName*(Comment :CXComment) :CXString {.importc:"clang_TParamCommandComment_getParamName", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_TParamCommand AST node.
## 
## \returns non-zero if the parameter that this AST node represents was found
## in the template parameter list and
## clang_TParamCommandComment_getDepth and
## clang_TParamCommandComment_getIndex functions will return a meaningful
## value.
proc clang_TParamCommandComment_isParamPositionValid*(Comment :CXComment) :cuint {.importc:"clang_TParamCommandComment_isParamPositionValid", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_TParamCommand AST node.
## 
## \returns zero-based nesting depth of this parameter in the template parameter list.
## 
## For example,
## \verbatim
##     template<typename C, template<typename T> class TT>
##     void test(TT<int> aaa);
## \endverbatim
## for C and TT nesting depth is 0,
## for T nesting depth is 1.
proc clang_TParamCommandComment_getDepth*(Comment :CXComment) :cuint {.importc:"clang_TParamCommandComment_getDepth", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_TParamCommand AST node.
## 
## \returns zero-based parameter index in the template parameter list at a
## given nesting depth.
## 
## For example,
## \verbatim
##     template<typename C, template<typename T> class TT>
##     void test(TT<int> aaa);
## \endverbatim
## for C and TT nesting depth is 0, so we can ask for index at depth 0:
## at depth 0 C's index is 0, TT's index is 1.
## 
## For T nesting depth is 1, so we can ask for index at depth 0 and 1:
## at depth 0 T's index is 1 (same as TT's),
## at depth 1 T's index is 0.
proc clang_TParamCommandComment_getIndex*(Comment :CXComment; Depth :cuint) :cuint {.importc:"clang_TParamCommandComment_getIndex", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_VerbatimBlockLine AST node.
## 
## \returns text contained in the AST node.
proc clang_VerbatimBlockLineComment_getText*(Comment :CXComment) :CXString {.importc:"clang_VerbatimBlockLineComment_getText", cdecl, dynlib:libclang.}
## 
## \param Comment a CXComment_VerbatimLine AST node.
## 
## \returns text contained in the AST node.
proc clang_VerbatimLineComment_getText*(Comment :CXComment) :CXString {.importc:"clang_VerbatimLineComment_getText", cdecl, dynlib:libclang.}
## 
## Convert an HTML tag AST node to string.
## 
## \param Comment a CXComment_HTMLStartTag or CXComment_HTMLEndTag AST
## node.
## 
## \returns string containing an HTML tag.
proc clang_HTMLTagComment_getAsString*(Comment :CXComment) :CXString {.importc:"clang_HTMLTagComment_getAsString", cdecl, dynlib:libclang.}
## 
## Convert a given full parsed comment to an HTML fragment.
## 
## Specific details of HTML layout are subject to change.  Don't try to parse
## this HTML back into an AST, use other APIs instead.
## 
## Currently the following CSS classes are used:
## \li "para-brief" for \paragraph and equivalent commands;
## \li "para-returns" for \\returns paragraph and equivalent commands;
## \li "word-returns" for the "Returns" word in \\returns paragraph.
## 
## Function argument documentation is rendered as a \<dl\> list with arguments
## sorted in function prototype order.  CSS classes used:
## \li "param-name-index-NUMBER" for parameter name (\<dt\>);
## \li "param-descr-index-NUMBER" for parameter description (\<dd\>);
## \li "param-name-index-invalid" and "param-descr-index-invalid" are used if
## parameter index is invalid.
## 
## Template parameter documentation is rendered as a \<dl\> list with
## parameters sorted in template parameter list order.  CSS classes used:
## \li "tparam-name-index-NUMBER" for parameter name (\<dt\>);
## \li "tparam-descr-index-NUMBER" for parameter description (\<dd\>);
## \li "tparam-name-index-other" and "tparam-descr-index-other" are used for
## names inside template template parameters;
## \li "tparam-name-index-invalid" and "tparam-descr-index-invalid" are used if
## parameter position is invalid.
## 
## \param Comment a CXComment_FullComment AST node.
## 
## \returns string containing an HTML fragment.
proc clang_FullComment_getAsHTML*(Comment :CXComment) :CXString {.importc:"clang_FullComment_getAsHTML", cdecl, dynlib:libclang.}
## 
## Convert a given full parsed comment to an XML document.
## 
## A Relax NG schema for the XML can be found in comment-xml-schema.rng file
## inside clang source tree.
## 
## \param Comment a CXComment_FullComment AST node.
## 
## \returns string containing an XML document.
proc clang_FullComment_getAsXML*(Comment :CXComment) :CXString {.importc:"clang_FullComment_getAsXML", cdecl, dynlib:libclang.}
type
  struct_CXAPISetImpl* {.incompleteStruct.} = object
  CXAPISetImpl* = struct_CXAPISetImpl
## 
## CXAPISet is an opaque type that represents a data structure containing all
## the API information for a given translation unit. This can be used for a
## single symbol symbol graph for a given symbol.
type CXAPISet* = ptr struct_CXAPISetImpl
## 
## Traverses the translation unit to create a CXAPISet.
## 
## \param tu is the CXTranslationUnit to build the CXAPISet for.
## 
## \param out_api is a pointer to the output of this function. It is needs to be
## disposed of by calling clang_disposeAPISet.
## 
## \returns Error code indicating success or failure of the APISet creation.
proc clang_createAPISet*(tu :CXTranslationUnit; out_api :ptr CXAPISet) :CXErrorCode {.importc:"clang_createAPISet", cdecl, dynlib:libclang.}
## 
## Dispose of an APISet.
## 
## The provided CXAPISet can not be used after this function is called.
proc clang_disposeAPISet*(api :CXAPISet) {.importc:"clang_disposeAPISet", cdecl, dynlib:libclang.}
## 
## Generate a single symbol symbol graph for the given USR. Returns a null
## string if the associated symbol can not be found in the provided CXAPISet.
## 
## The output contains the symbol graph as well as some additional information
## about related symbols.
## 
## \param usr is a string containing the USR of the symbol to generate the
## symbol graph for.
## 
## \param api the CXAPISet to look for the symbol in.
## 
## \returns a string containing the serialized symbol graph representation for
## the symbol being queried or a null string if it can not be found in the
## APISet.
proc clang_getSymbolGraphForUSR*(usr :cstring; api :CXAPISet) :CXString {.importc:"clang_getSymbolGraphForUSR", cdecl, dynlib:libclang.}
## 
## Generate a single symbol symbol graph for the declaration at the given
## cursor. Returns a null string if the AST node for the cursor isn't a
## declaration.
## 
## The output contains the symbol graph as well as some additional information
## about related symbols.
## 
## \param cursor the declaration for which to generate the single symbol symbol
## graph.
## 
## \returns a string containing the serialized symbol graph representation for
## the symbol being queried or a null string if it can not be found in the
## APISet.
proc clang_getSymbolGraphForCursor*(cursor :CXCursor) :CXString {.importc:"clang_getSymbolGraphForCursor", cdecl, dynlib:libclang.}
type CXRewriter* = pointer
## 
## Create CXRewriter.
proc clang_CXRewriter_create*(TU :CXTranslationUnit) :CXRewriter {.importc:"clang_CXRewriter_create", cdecl, dynlib:libclang.}
## 
## Insert the specified string at the specified location in the original buffer.
proc clang_CXRewriter_insertTextBefore*(Rew :CXRewriter; Loc :CXSourceLocation; Insert :cstring) {.importc:"clang_CXRewriter_insertTextBefore", cdecl, dynlib:libclang.}
## 
## Replace the specified range of characters in the input with the specified
## replacement.
proc clang_CXRewriter_replaceText*(Rew :CXRewriter; ToBeReplaced :CXSourceRange; Replacement :cstring) {.importc:"clang_CXRewriter_replaceText", cdecl, dynlib:libclang.}
## 
## Remove the specified range.
proc clang_CXRewriter_removeText*(Rew :CXRewriter; ToBeRemoved :CXSourceRange) {.importc:"clang_CXRewriter_removeText", cdecl, dynlib:libclang.}
## 
## Save all changed files to disk.
## Returns 1 if any files were not saved successfully, returns 0 otherwise.
proc clang_CXRewriter_overwriteChangedFiles*(Rew :CXRewriter) :cint {.importc:"clang_CXRewriter_overwriteChangedFiles", cdecl, dynlib:libclang.}
## 
## Write out rewritten version of the main file to stdout.
proc clang_CXRewriter_writeMainFileToStdOut*(Rew :CXRewriter) {.importc:"clang_CXRewriter_writeMainFileToStdOut", cdecl, dynlib:libclang.}
## 
## Free the given CXRewriter.
proc clang_CXRewriter_dispose*(Rew :CXRewriter) {.importc:"clang_CXRewriter_dispose", cdecl, dynlib:libclang.}
