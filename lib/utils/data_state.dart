/// Data state distinguishing "there are rows" from "zero rows is normal".
sealed class DataState<T> {
  const DataState();
}

/// The data source produced [data].
final class HasData<T> extends DataState<T> {
  /// Creates the state holding [data].
  const HasData(this.data);

  /// The produced rows.
  final T data;
}

/// The data source legitimately has no rows.
final class NoData<T> extends DataState<T> {
  /// Creates the empty state.
  const NoData();
}
