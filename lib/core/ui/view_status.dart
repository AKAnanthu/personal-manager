/// Loading state of a watched list.
enum LoadStatus { loading, ready, failure }

/// How an editor page finished; the page pops on anything but [none].
enum EditorOutcome { none, saved, archived, deleted, discarded }
