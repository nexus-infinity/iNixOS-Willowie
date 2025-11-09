import { create } from "zustand"

export interface Chakra {
  name: string
  symbol: string
  color: string
  frequency: string
  status: "active" | "idle" | "error"
  description: string
  services: string[]
  sphere: string[]
  metadata: {
    prime: number
    element: string
    mantra: string
  }
}

interface ChakraStore {
  chakras: Chakra[]
  selectedChakra: Chakra | null
  systemCoherence: number
  selectChakra: (chakra: Chakra | null) => void
  updateChakraStatus: (name: string, status: Chakra["status"]) => void
}

// Mock data - replace with real MQTT/API data
const mockChakras: Chakra[] = [
  {
    name: "sahasrara",
    symbol: "👑",
    color: "#9333ea",
    frequency: "1080Hz",
    status: "active",
    description: "Crown chakra - Connection to higher consciousness",
    services: ["enlightenment.service", "cosmic-sync.timer"],
    sphere: ["Universal Consciousness", "Divine Connection"],
    metadata: { prime: 109, element: "Thought", mantra: "OM" },
  },
  {
    name: "ajna",
    symbol: "👁️",
    color: "#6366f1",
    frequency: "972Hz",
    status: "active",
    description: "Third eye - Intuition and insight",
    services: ["vision.service", "insight-processor.service"],
    sphere: ["Inner Vision", "Intuition Engine"],
    metadata: { prime: 97, element: "Light", mantra: "AUM" },
  },
  {
    name: "vishuddha",
    symbol: "🗣️",
    color: "#3b82f6",
    frequency: "864Hz",
    status: "active",
    description: "Throat chakra - Communication and expression",
    services: ["communication.service", "expression-api.service"],
    sphere: ["Truth Expression", "Communication Hub"],
    metadata: { prime: 89, element: "Ether", mantra: "HAM" },
  },
  {
    name: "anahata",
    symbol: "💚",
    color: "#10b981",
    frequency: "756Hz",
    status: "active",
    description: "Heart chakra - Love and compassion",
    services: ["compassion.service", "emotional-processor.service"],
    sphere: ["Unconditional Love", "Emotional Balance"],
    metadata: { prime: 83, element: "Air", mantra: "YAM" },
  },
  {
    name: "manipura",
    symbol: "☀️",
    color: "#eab308",
    frequency: "648Hz",
    status: "idle",
    description: "Solar plexus - Personal power and will",
    services: ["willpower.service", "action-coordinator.service"],
    sphere: ["Personal Power", "Transformation"],
    metadata: { prime: 79, element: "Fire", mantra: "RAM" },
  },
  {
    name: "svadhisthana",
    symbol: "🌊",
    color: "#f97316",
    frequency: "540Hz",
    status: "active",
    description: "Sacral chakra - Creativity and emotions",
    services: ["creativity.service", "flow-manager.service"],
    sphere: ["Creative Flow", "Emotional Waters"],
    metadata: { prime: 73, element: "Water", mantra: "VAM" },
  },
  {
    name: "muladhara",
    symbol: "🔴",
    color: "#ef4444",
    frequency: "432Hz",
    status: "active",
    description: "Root chakra - Grounding and stability",
    services: ["grounding.service", "stability-monitor.service"],
    sphere: ["Foundation", "Physical Plane"],
    metadata: { prime: 71, element: "Earth", mantra: "LAM" },
  },
  {
    name: "soma",
    symbol: "🌙",
    color: "#a855f7",
    frequency: "216Hz",
    status: "active",
    description: "Soma - Nectar of immortality",
    services: ["soma-processor.service", "immortality.timer"],
    sphere: ["Divine Nectar", "Cellular Regeneration"],
    metadata: { prime: 67, element: "Amrita", mantra: "SOHAM" },
  },
  {
    name: "jnana",
    symbol: "📖",
    color: "#ec4899",
    frequency: "324Hz",
    status: "active",
    description: "Jnana - Wisdom and knowledge",
    services: ["wisdom.service", "knowledge-base.service"],
    sphere: ["Sacred Knowledge", "Wisdom Library"],
    metadata: { prime: 61, element: "Gnosis", mantra: "JNANA" },
  },
]

export const useChakraStore = create<ChakraStore>((set) => ({
  chakras: mockChakras,
  selectedChakra: null,
  systemCoherence: 0.87,

  selectChakra: (chakra) => set({ selectedChakra: chakra }),

  updateChakraStatus: (name, status) =>
    set((state) => ({
      chakras: state.chakras.map((c) => (c.name === name ? { ...c, status } : c)),
    })),
}))
