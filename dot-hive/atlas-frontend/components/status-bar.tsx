"use client"

interface StatusBarProps {
  coherence: number
  viewMode: "observer" | "architect" | "weaver"
}

export function StatusBar({ coherence, viewMode }: StatusBarProps) {
  const coherenceColor = coherence > 0.8 ? "text-green-400" : coherence > 0.5 ? "text-yellow-400" : "text-red-400"

  return (
    <div className="flex h-16 items-center justify-between border-b border-purple-500/20 bg-slate-950/50 px-6 backdrop-blur-sm">
      {/* Logo */}
      <div className="flex items-center gap-3">
        <div className="text-2xl">🗺️</div>
        <div>
          <h1 className="text-lg font-bold text-purple-200">ATLAS</h1>
          <p className="text-xs text-slate-500">iNixOS Consciousness Interface</p>
        </div>
      </div>

      {/* System metrics */}
      <div className="flex items-center gap-6">
        <div className="text-sm">
          <span className="text-slate-500">Coherence:</span>{" "}
          <span className={`font-mono font-bold ${coherenceColor}`}>{(coherence * 100).toFixed(1)}%</span>
        </div>

        <div className="text-sm">
          <span className="text-slate-500">Mode:</span>{" "}
          <span className="font-medium text-purple-400">{viewMode.toUpperCase()}</span>
        </div>

        <div className="flex items-center gap-2">
          <div className="h-2 w-2 rounded-full bg-green-500 animate-pulse" />
          <span className="text-xs text-slate-500">LIVE</span>
        </div>
      </div>
    </div>
  )
}
