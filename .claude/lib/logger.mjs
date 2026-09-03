// SYNCED from _shared/common/lib/logger.mjs — edit there, not here.
// Structured logger. One JSON line per event. Used by scripts and agents.
export function createLogger(scope) {
  const emit = (level, msg, meta = {}) =>
    process.stdout.write(
      JSON.stringify({ ts: new Date().toISOString(), level, scope, msg, ...meta }) + '\n',
    );
  return {
    info: (msg, meta) => emit('info', msg, meta),
    warn: (msg, meta) => emit('warn', msg, meta),
    error: (msg, meta) => emit('error', msg, meta),
  };
}
