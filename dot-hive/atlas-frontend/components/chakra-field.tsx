"use client"

import { ChakraNode } from "./chakra-node"
import { useChakraStore } from "@/lib/chakra-store"

interface ChakraFieldProps {
  viewMode: "observer" | "architect" | "weaver"
}

export function ChakraField({ viewMode }: ChakraFieldProps) {
  const { chakras, selectChakra } = useChakraStore()

  // Hexagonal layout positions (Flower of Life pattern)
  const positions = [
    { x: 0, y: -200, label: "top" }, // Sahasrara (crown)
    { x: 173, y: -100, label: "top-right" }, // Ajna (third eye)
    { x: 173, y: 100, label: "right" }, // Vishuddha (throat)
    { x: 0, y: 200, label: "bottom" }, // Anahata (heart) - center
    { x: -173, y: 100, label: "left" }, // Manipura (solar plexus)
    { x: -173, y: -100, label: "top-left" }, // Svadhisthana (sacral)
    { x: 0, y: 0, label: "center" }, // Muladhara (root) - DOJO center
    { x: 87, y: 0, label: "center-right" }, // Soma
    { x: -87, y: 0, label: "center-left" }, // Jnana
  ]

  return (
    <div className="relative h-[600px] w-[600px]">
      {/* Central DOJO pulse */}
      <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
        <div className="h-32 w-32 rounded-full border-2 border-purple-500/30 animate-pulse-sacred" />
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center">
            <div className="text-2xl font-bold text-purple-400">DOJO</div>
            <div className="text-xs text-purple-600">108Hz</div>
          </div>
        </div>
      </div>

      {/* Connecting lines (sacred geometry) */}
      <svg className="absolute inset-0 pointer-events-none opacity-20">
        <defs>
          <linearGradient id="line-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="rgb(168, 85, 247)" stopOpacity="0" />
            <stop offset="50%" stopColor="rgb(168, 85, 247)" stopOpacity="0.5" />
            <stop offset="100%" stopColor="rgb(168, 85, 247)" stopOpacity="0" />
          </linearGradient>
        </defs>
        {positions.map((pos, i) =>
          positions
            .slice(i + 1)
            .map((pos2, j) => (
              <line
                key={`${i}-${j}`}
                x1={300 + pos.x}
                y1={300 + pos.y}
                x2={300 + pos2.x}
                y2={300 + pos2.y}
                stroke="url(#line-gradient)"
                strokeWidth="1"
              />
            )),
        )}
      </svg>

      {/* Chakra nodes */}
      {chakras.map((chakra, i) => (
        <div
          key={chakra.name}
          className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2"
          style={{
            transform: `translate(calc(-50% + ${positions[i].x}px), calc(-50% + ${positions[i].y}px))`,
          }}
        >
          <ChakraNode chakra={chakra} viewMode={viewMode} onClick={() => selectChakra(chakra)} />
        </div>
      ))}
    </div>
  )
}
