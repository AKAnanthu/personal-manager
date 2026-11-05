import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// Debounces events, then cancels any in-flight handler for the previous
/// one (search-as-you-type).
EventTransformer<E> debounceRestartable<E>([
  Duration duration = const Duration(milliseconds: 250),
]) =>
    (events, mapper) => events.debounce(duration).switchMap(mapper);
