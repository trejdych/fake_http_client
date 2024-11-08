import 'dart:io';

class FakeHttpHeaders implements HttpHeaders {
  FakeHttpHeaders([this._headers = const {}]);

  final Map<String, List<String>> _headers;

  /// The date specified by the [HttpHeaders.dateHeader] header, if any.
  @override
  DateTime? date;

  /// The date and time specified by the [HttpHeaders.expiresHeader] header, if any.
  @override
  DateTime? expires;

  /// The date and time specified by the [HttpHeaders.ifModifiedSinceHeader] header, if any.
  @override
  DateTime? ifModifiedSince;

  /// The value of the [HttpHeaders.hostHeader] header, if any.
  @override
  String? host;

  /// The value of the port part of the [HttpHeaders.hostHeader] header, if any.
  @override
  int? port;

  /// The [ContentType] of the [HttpHeaders.contentTypeHeader] header, if any.
  @override
  ContentType? contentType;

  /// The value of the [HttpHeaders.contentLengthHeader] header, if any.
  ///
  /// The value is negative if there is no content length set.
  @override
  int contentLength = -1;

  /// Whether the connection is persistent (keep-alive).
  @override
  bool persistentConnection = true;

  /// Whether the connection uses chunked transfer encoding.
  ///
  /// Reflects and modifies the value of the [HttpHeaders.transferEncodingHeader] header.
  @override
  bool chunkedTransferEncoding = false;

  /// The values for the header named [name].
  ///
  /// Returns null if there is no header with the provided name,
  /// otherwise returns a new list containing the current values.
  /// Not that modifying the list does not change the header.
  @override
  List<String>? operator [](String name) {
    return _headers[name];
  }

  /// Convenience method for the value for a single valued header.
  ///
  /// The value must not have more than one value.
  ///
  /// Returns `null` if there is no header with the provided name.
  @override
  String? value(String name) {
    final values = _headers[name];
    if (values == null) {
      return null;
    }
    if (values.length != 1) {
      throw StateError('Header $name has more than one value');
    }

    return values.single;
  }

  /// Adds a header value.
  ///
  /// The header named [name] will have a string value derived from [value]
  /// added to its list of values.
  ///
  /// Some headers are single valued, and for these, adding a value will
  /// replace a previous value. If the [value] is a [DateTime], an
  /// HTTP date format will be applied. If the value is an [Iterable],
  /// each element will be added separately. For all other
  /// types the default [Object.toString] method will be used.
  ///
  /// Header names are converted to lower-case unless
  /// [preserveHeaderCase] is set to true. If two header names are
  /// the same when converted to lower-case, they are considered to be
  /// the same header, with one set of values.
  ///
  /// The current case of the a header name is that of the name used by
  /// the last [set] or [add] call for that header.
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) =>
      _headers.putIfAbsent(name, () => []).add(value.toString());

  /// Sets the header [name] to [value].
  ///
  /// Removes all existing values for the header named [name] and
  /// then [add]s [value] to it.
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers[name] = [value.toString()];
  }

  /// Removes a specific value for a header name.
  ///
  /// Some headers have system supplied values which cannot be removed.
  /// For all other headers and values, the [value] is converted to a string
  /// in the same way as for [add], then that string value is removed from the
  /// current values of [name].
  /// If there are no remaining values for [name], the header is no longer
  /// considered present.
  @override
  void remove(String name, Object value) =>
      _headers[name]?.remove(value.toString());

  /// Removes all values for the specified header name.
  ///
  /// Some headers have system supplied values which cannot be removed.
  /// All other values for [name] are removed.
  /// If there are no remaining values for [name], the header is no longer
  /// considered present.
  @override
  void removeAll(String name) => _headers.remove(name);

  /// Performs the [action] on each header.
  ///
  /// The [action] function is called with each header's name and a list
  /// of the header's values. The casing of the name string is determined by
  /// the last [add] or [set] operation for that particular header,
  /// which defaults to lower-casing the header name unless explicitly
  /// set to preserve the case.
  @override
  void forEach(void Function(String name, List<String> values) action) =>
      _headers.forEach(action);

  /// Disables folding for the header named [name] when sending the HTTP header.
  ///
  /// By default, multiple header values are folded into a
  /// single header line by separating the values with commas.
  ///
  /// The 'set-cookie' header has folding disabled by default.
  @override
  void noFolding(String name) {}

  /// Removes all headers.
  ///
  /// Some headers have system supplied values which cannot be removed.
  /// All other header values are removed, and header names with not
  /// remaining values are no longer considered present.
  @override
  void clear() => _headers.clear();
}
