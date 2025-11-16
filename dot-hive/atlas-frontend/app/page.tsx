"use client"

import { useState, useEffect } from "react"
import { ChakraField } from "@/components/chakra-field"
import { ControlPanel } from "@/components/control-panel"
import { StatusBar } from "@/components/status-bar"
import { ChakraInspector } from "@/components/chakra-inspector"
import { TerminalPanel } from "@/components/terminal-panel"
import { useChakraStore } from "@/lib/chakra-store"

export default function AtlasPage() {
  const [viewMode, setViewMode] = useState<"observer" | "architect" | "weaver">("observer")
  const [showTerminal, setShowTerminal] = useState(false)
  const store = useChakraStore()
  const selectedChakra = store.selectedChakra
  const systemCoherence = store.systemCoherence

  return (
    <div className="relative h-screen w-screen overflow-hidden bg-gradient-to-b from-slate-950 via-purple-950/20 to-slate-950">
      {/* Cosmic background effect */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(ellipse_at_center,_var(--tw-gradient-stops))] from-purple-900/10 via-transparent to-transparent" />

      {/* Sacred geometry overlay */}
      <div className="pointer-events-none absolute inset-0 opacity-5">
        <svg className="h-full w-full">
          <defs>
            <pattern id="hexagons" width="100" height="87" patternUnits="userSpaceOnUse">
              <path
                d="M50 0L93.3 25L93.3 75L50 100L6.7 75L6.7 25Z"
                fill="none"
                stroke="currentColor"
                strokeWidth="0.5"
              />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#hexagons)" />
        </svg>
      </div>

      {/* Status Bar */}
      <StatusBar coherence={systemCoherence} viewMode={viewMode} />

      {/* Main Content */}
      <div className="relative z-10 flex h-[calc(100vh-4rem)] w-full">
        {/* Left Panel - Chakra Field */}
        <div className="flex-1 flex items-center justify-center p-8">
          <ChakraField viewMode={viewMode} />
        </div>

        {/* Right Panel - Inspector or Terminal */}
        <div className="w-96 border-l border-purple-500/20 bg-slate-950/50 backdrop-blur-sm">
          {showTerminal ? (
            <TerminalPanel onClose={() => setShowTerminal(false)} />
          ) : !selectedChakra ? (
            <div className="flex h-full items-center justify-center p-8 text-center">
              <div className="space-y-4">
                <div className="text-6xl">🕉️</div>
                <p className="text-sm text-slate-400">Select a chakra node to inspect</p>
                <p className="text-xs text-slate-500">
                  or press <kbd className="rounded bg-slate-800 px-2 py-1 text-xs">T</kbd> for terminal
                </p>
              </div>
            </div>
          ) : (
            <ChakraInspector chakra={selectedChakra} onClose={() => store.selectChakra(null)} />
          )}
        </div>
      </div>

      {/* Control Panel */}
      <ControlPanel
        viewMode={viewMode}
        onViewModeChange={setViewMode}
        onToggleTerminal={() => setShowTerminal(!showTerminal)}
      />

      {/* Keyboard shortcuts */}
      <div className="fixed bottom-4 left-4 text-xs text-slate-600">
        <kbd className="rounded bg-slate-900 px-2 py-1">1-9</kbd> Select chakra •{" "}
        <kbd className="rounded bg-slate-900 px-2 py-1">T</kbd> Terminal •{" "}
        <kbd className="rounded bg-slate-900 px-2 py-1">ESC</kbd> Close panel
      </div>

      {/* Global keyboard handler */}
      <KeyboardHandler
        onToggleTerminal={() => setShowTerminal(!showTerminal)}
        onClosePanel={() => {
          setShowTerminal(false)
          store.selectChakra(null)
        }}
      />
    </div>
  )
}

function KeyboardHandler({
  onToggleTerminal,
  onClosePanel,
}: {
  onToggleTerminal: () => void
  onClosePanel: () => void
}) {
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === "t" || e.key === "T") {
        onToggleTerminal()
      } else if (e.key === "Escape") {
        onClosePanel()
      }
    }
    window.addEventListener("keydown", handler)
    return () => window.removeEventListener("keydown", handler)
  }, [onToggleTerminal, onClosePanel])

  return null
}
