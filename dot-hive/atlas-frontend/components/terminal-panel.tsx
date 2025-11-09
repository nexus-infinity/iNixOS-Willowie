"use client"

import { useState, useRef, useEffect } from "react"
import { X } from "lucide-react"
import { useChakraStore } from "@/lib/chakra-store"

interface TerminalPanelProps {
  onClose: () => void
}

export function TerminalPanel({ onClose }: TerminalPanelProps) {
  const [input, setInput] = useState("")
  const [history, setHistory] = useState<Array<{ type: "input" | "output" | "error"; text: string }>>([
    { type: "output", text: "Atlas Terminal v1.0.0" },
    { type: "output", text: 'Type "help" for available commands' },
  ])
  const inputRef = useRef<HTMLInputElement>(null)
  const { chakras, systemCoherence, selectChakra } = useChakraStore()

  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  const executeCommand = (cmd: string) => {
    const parts = cmd.trim().toLowerCase().split(" ")
    const command = parts[0]
    const args = parts.slice(1)

    setHistory((prev) => [...prev, { type: "input", text: `$ ${cmd}` }])

    switch (command) {
      case "help":
        setHistory((prev) => [
          ...prev,
          { type: "output", text: "Available commands:" },
          { type: "output", text: "  list              - List all chakra nodes" },
          { type: "output", text: "  inspect <chakra>  - Inspect chakra details" },
          { type: "output", text: "  status            - Show system status" },
          { type: "output", text: "  coherence         - Show coherence levels" },
          { type: "output", text: "  clear             - Clear terminal" },
          { type: "output", text: "  help              - Show this help" },
        ])
        break

      case "list":
        setHistory((prev) => [
          ...prev,
          { type: "output", text: "Chakra Nodes:" },
          ...chakras.map((c) => ({
            type: "output" as const,
            text: `  ${c.name.padEnd(15)} [${c.status}] ${c.frequency}`,
          })),
        ])
        break

      case "inspect":
        if (args.length === 0) {
          setHistory((prev) => [...prev, { type: "error", text: "Usage: inspect <chakra-name>" }])
        } else {
          const chakra = chakras.find((c) => c.name.toLowerCase().includes(args[0]))
          if (chakra) {
            selectChakra(chakra)
            onClose()
          } else {
            setHistory((prev) => [...prev, { type: "error", text: `Chakra not found: ${args[0]}` }])
          }
        }
        break

      case "status":
        setHistory((prev) => [
          ...prev,
          { type: "output", text: "System Status:" },
          { type: "output", text: `  Total Nodes: ${chakras.length}` },
          { type: "output", text: `  Active: ${chakras.filter((c) => c.status === "active").length}` },
          { type: "output", text: `  Idle: ${chakras.filter((c) => c.status === "idle").length}` },
          { type: "output", text: `  Errors: ${chakras.filter((c) => c.status === "error").length}` },
        ])
        break

      case "coherence":
        setHistory((prev) => [
          ...prev,
          { type: "output", text: `Global Coherence: ${(systemCoherence * 100).toFixed(1)}%` },
          {
            type: "output",
            text:
              systemCoherence > 0.8
                ? "  Status: Excellent ✨"
                : systemCoherence > 0.5
                  ? "  Status: Good"
                  : "  Status: Needs attention ⚠️",
          },
        ])
        break

      case "clear":
        setHistory([])
        break

      case "":
        break

      default:
        setHistory((prev) => [...prev, { type: "error", text: `Command not found: ${command}` }])
    }

    setInput("")
  }

  return (
    <div className="flex h-full flex-col bg-slate-950">
      {/* Header */}
      <div className="flex items-center justify-between border-b border-purple-500/20 p-4">
        <div className="flex items-center gap-2">
          <span className="text-lg">⌨️</span>
          <h2 className="text-sm font-bold text-purple-200">TERMINAL</h2>
        </div>
        <button onClick={onClose} className="rounded p-1 text-slate-500 hover:bg-slate-800 hover:text-slate-300">
          <X className="h-4 w-4" />
        </button>
      </div>

      {/* Terminal output */}
      <div className="flex-1 overflow-auto p-4 font-mono text-sm">
        {history.map((line, i) => (
          <div
            key={i}
            className={`
              ${line.type === "input" ? "text-purple-400" : ""}
              ${line.type === "output" ? "text-slate-300" : ""}
              ${line.type === "error" ? "text-red-400" : ""}
            `}
          >
            {line.text}
          </div>
        ))}
      </div>

      {/* Input */}
      <div className="border-t border-purple-500/20 p-4">
        <div className="flex items-center gap-2">
          <span className="text-purple-400">$</span>
          <input
            ref={inputRef}
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") executeCommand(input)
            }}
            className="flex-1 bg-transparent font-mono text-sm text-slate-200 outline-none"
            placeholder="Type a command..."
          />
        </div>
      </div>
    </div>
  )
}
