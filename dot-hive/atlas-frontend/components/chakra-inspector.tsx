"use client"

import type { Chakra } from "@/lib/chakra-store"
import { X } from "lucide-react"

interface ChakraInspectorProps {
  chakra: Chakra | null | undefined
  onClose: () => void
}

export function ChakraInspector({ chakra, onClose }: ChakraInspectorProps) {
  if (!chakra) {
    return (
      <div className="flex h-full items-center justify-center p-8 text-center">
        <div className="space-y-4">
          <p className="text-sm text-slate-400">No chakra data available</p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex h-full flex-col">
      {/* Header */}
      <div className="flex items-center justify-between border-b border-purple-500/20 p-4">
        <div className="flex items-center gap-3">
          <div className="text-3xl">{chakra.symbol || "?"}</div>
          <div>
            <h2 className="text-lg font-bold" style={{ color: chakra.color }}>
              {(chakra.name || "unknown").toUpperCase()}
            </h2>
            <p className="text-xs text-slate-500">{chakra.frequency || "N/A"}</p>
          </div>
        </div>
        <button onClick={onClose} className="rounded p-1 text-slate-500 hover:bg-slate-800 hover:text-slate-300">
          <X className="h-4 w-4" />
        </button>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-4 space-y-4">
        {/* Status */}
        <div className="rounded-lg border border-purple-500/20 bg-slate-900/50 p-3">
          <div className="text-xs text-slate-500 uppercase mb-2">Status</div>
          <div className="flex items-center gap-2">
            <div
              className={`h-2 w-2 rounded-full ${
                chakra.status === "active" ? "bg-green-500" : chakra.status === "idle" ? "bg-yellow-500" : "bg-red-500"
              }`}
            />
            <span className="text-sm font-medium capitalize">{chakra.status || "unknown"}</span>
          </div>
        </div>

        {/* Description */}
        <div className="rounded-lg border border-purple-500/20 bg-slate-900/50 p-3">
          <div className="text-xs text-slate-500 uppercase mb-2">Description</div>
          <p className="text-sm text-slate-300">{chakra.description || "No description available"}</p>
        </div>

        {/* Services */}
        <div className="rounded-lg border border-purple-500/20 bg-slate-900/50 p-3">
          <div className="text-xs text-slate-500 uppercase mb-2">Services</div>
          <div className="space-y-2">
            {(chakra.services || []).map((service) => (
              <div key={service} className="flex items-center gap-2 rounded bg-slate-800/50 px-3 py-2">
                <div className="h-1.5 w-1.5 rounded-full bg-green-500" />
                <span className="font-mono text-xs text-slate-300">{service}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Sphere Ecosystem */}
        <div className="rounded-lg border border-purple-500/20 bg-slate-900/50 p-3">
          <div className="text-xs text-slate-500 uppercase mb-2">Sphere Ecosystem</div>
          <div className="space-y-1">
            {(chakra.sphere || []).map((item) => (
              <div key={item} className="text-xs text-slate-400">
                • {item}
              </div>
            ))}
          </div>
        </div>

        {/* Metadata */}
        {chakra.metadata && (
          <div className="rounded-lg border border-purple-500/20 bg-slate-900/50 p-3">
            <div className="text-xs text-slate-500 uppercase mb-2">Metadata</div>
            <div className="space-y-1 font-mono text-xs">
              <div className="flex justify-between">
                <span className="text-slate-500">Prime:</span>
                <span className="text-slate-300">{chakra.metadata.prime || "N/A"}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Element:</span>
                <span className="text-slate-300">{chakra.metadata.element || "N/A"}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Mantra:</span>
                <span className="text-slate-300">{chakra.metadata.mantra || "N/A"}</span>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
