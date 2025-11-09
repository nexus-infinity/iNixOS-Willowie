"use client"

import type { Chakra } from "@/lib/chakra-store"

interface ChakraNodeProps {
  chakra: Chakra
  viewMode: "observer" | "architect" | "weaver"
  onClick: () => void
}

export function ChakraNode({ chakra, viewMode, onClick }: ChakraNodeProps) {
  const statusColor = {
    active: "bg-green-500",
    idle: "bg-yellow-500",
    error: "bg-red-500",
  }[chakra.status]

  const statusGlow = {
    active: "shadow-[0_0_20px_rgba(34,197,94,0.5)]",
    idle: "shadow-[0_0_20px_rgba(234,179,8,0.5)]",
    error: "shadow-[0_0_20px_rgba(239,68,68,0.5)]",
  }[chakra.status]

  return (
    <button
      onClick={onClick}
      className="group relative flex h-24 w-24 flex-col items-center justify-center rounded-full border-2 transition-all duration-300 hover:scale-110 hover:z-10"
      style={{
        borderColor: chakra.color,
        backgroundColor: `${chakra.color}15`,
      }}
    >
      {/* Pulse effect */}
      <div
        className={`absolute inset-0 rounded-full opacity-0 group-hover:opacity-20 group-hover:animate-ping`}
        style={{ backgroundColor: chakra.color }}
      />

      {/* Chakra info */}
      <div className="relative z-10 text-center">
        <div className="text-xl mb-1">{chakra.symbol}</div>
        <div className="text-xs font-medium" style={{ color: chakra.color }}>
          {chakra.name.toUpperCase()}
        </div>
        <div className="text-[10px] text-slate-500">{chakra.frequency}</div>
      </div>

      {/* Status indicator */}
      <div className={`absolute -top-1 -right-1 h-3 w-3 rounded-full ${statusColor} ${statusGlow}`} />

      {/* View mode indicator */}
      {viewMode === "architect" && (
        <div className="absolute -bottom-2 left-1/2 -translate-x-1/2 text-[10px] text-purple-400">
          {chakra.services.length}
        </div>
      )}
    </button>
  )
}
