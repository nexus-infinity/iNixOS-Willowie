"use client"

interface ControlPanelProps {
  viewMode: "observer" | "architect" | "weaver"
  onViewModeChange: (mode: "observer" | "architect" | "weaver") => void
  onToggleTerminal: () => void
}

export function ControlPanel({ viewMode, onViewModeChange, onToggleTerminal }: ControlPanelProps) {
  const modes = [
    { id: "observer" as const, icon: "👁️", label: "Observer", desc: "View & Monitor" },
    { id: "architect" as const, icon: "🏗️", label: "Architect", desc: "Design & Configure" },
    { id: "weaver" as const, icon: "🕸️", label: "Weaver", desc: "Execute & Deploy" },
  ]

  return (
    <div className="fixed bottom-8 left-1/2 -translate-x-1/2 flex items-center gap-4 rounded-full border border-purple-500/30 bg-slate-950/80 px-6 py-3 backdrop-blur-md">
      {/* Mode selector */}
      <div className="flex gap-2">
        {modes.map((mode) => (
          <button
            key={mode.id}
            onClick={() => onViewModeChange(mode.id)}
            className={`group relative flex flex-col items-center gap-1 rounded-lg px-4 py-2 transition-all ${
              viewMode === mode.id
                ? "bg-purple-500/20 text-purple-300"
                : "text-slate-500 hover:bg-slate-800 hover:text-slate-300"
            }`}
          >
            <div className="text-xl">{mode.icon}</div>
            <div className="text-xs font-medium">{mode.label}</div>

            {/* Tooltip */}
            <div className="absolute -top-12 left-1/2 -translate-x-1/2 whitespace-nowrap rounded bg-slate-900 px-3 py-1 text-xs opacity-0 transition-opacity group-hover:opacity-100 pointer-events-none">
              {mode.desc}
            </div>
          </button>
        ))}
      </div>

      {/* Divider */}
      <div className="h-8 w-px bg-purple-500/30" />

      {/* Terminal toggle */}
      <button
        onClick={onToggleTerminal}
        className="flex items-center gap-2 rounded-lg px-4 py-2 text-sm text-slate-400 transition-all hover:bg-slate-800 hover:text-slate-300"
      >
        <span className="text-lg">⌨️</span>
        <span>Terminal</span>
      </button>
    </div>
  )
}
