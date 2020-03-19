This folder contains the debug adapter's source-map support.

It contains the [`SourceMappingSourceActorProxy`](./source.ts), which implements the same interface
as the [`SourceActorProxy`](../actorProxy/source.ts).
When debugging source-mapped sources, there will be a `SourceActorProxy` for each generated source
and, on top of that, a `SourceMappingSourceActorProxy` for each original source. Unlike other
`ActorProxy` implementations, a `SourceMappingSourceActorProxy` does not correspond (and talk)
directly to a Firefox actor. Instead, it forwards all requests, responses and events to/from the
`SourceActorProxy` for the corresponding generated source, translating between original and
generated locations on-the-fly.

Likewise, there is the [`SourceMappingThreadActorProxy`](./thread.ts) working on top of a
regular [`ThreadActorProxy`](../actorProxy/thread.ts), fetching and processing source-maps, creating the
`SourceMappingSourceActorProxy` for each original source and translating between original and
generated locations in the messages forwarded to/from the corresponding `ThreadActorProxy`.
