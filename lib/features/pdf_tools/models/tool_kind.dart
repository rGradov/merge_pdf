/// The operation that produced a file.
enum ToolKind {
  /// Files combined into one.
  merge,

  /// One file split into many.
  split,

  /// Pages rotated.
  rotate,
}
