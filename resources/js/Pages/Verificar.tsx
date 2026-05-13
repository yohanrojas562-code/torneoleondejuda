import { useState } from 'react';
import { PageProps } from '@/types';
import { Head, Link, router } from '@inertiajs/react';
import { AnimatePresence, motion } from 'framer-motion';
import {
    ShieldCheck, ArrowLeft, Search, User as UserIcon, CheckCircle2, AlertTriangle, XCircle, ScanLine,
} from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';
import QrScannerOverlay from '@/Components/QrScannerOverlay';

interface TeamRef { id: number; name: string; short_name: string | null; logo: string | null; primary_color: string | null; }
interface PlayerResult {
    id: number;
    unique_code: string | null;
    first_name: string;
    last_name: string;
    photo: string | null;
    jersey_number: number | null;
    jersey_name: string | null;
    position: string | null;
    church: string | null;
    document_type: string | null;
    document_number: string | null;
    birth_date: string | null;
    age: number | null;
    blood_type: string | null;
    approval_status: string;
    is_captain: boolean;
    team: TeamRef | null;
    stats: {
        goals: number;
        matches: number;
        yellow_cards: number;
        blue_cards: number;
        red_cards: number;
    };
}

type Props = PageProps<{
    query: string;
    players: PlayerResult[];
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };

const statusConfig: Record<string, { label: string; bg: string; text: string; icon: typeof CheckCircle2 }> = {
    approved: { label: 'Aprobado', bg: 'bg-green-500/15', text: 'text-green-400', icon: CheckCircle2 },
    pending: { label: 'Pendiente', bg: 'bg-yellow-500/15', text: 'text-yellow-400', icon: AlertTriangle },
    rejected: { label: 'Rechazado', bg: 'bg-red-500/15', text: 'text-red-400', icon: XCircle },
};

const positionLabels: Record<string, string> = {
    portero: 'Portero',
    defensa: 'Defensa',
    mediocampista: 'Mediocampista',
    delantero: 'Delantero',
};

function PlayerPhoto({ player, size = 'lg' }: { player: PlayerResult; size?: 'sm' | 'md' | 'lg' }) {
    const dim = size === 'lg' ? 144 : size === 'md' ? 80 : 48;
    const fontSize = size === 'lg' ? '4rem' : size === 'md' ? '2rem' : '1.25rem';

    if (player.photo) {
        return (
            <img
                src={`/storage/${player.photo}`}
                alt={`${player.first_name} ${player.last_name}`}
                width={dim}
                height={dim}
                className="rounded-2xl object-cover border-2 border-brand-gold/30"
                style={{ width: dim, height: dim }}
            />
        );
    }

    const initial = (player.first_name?.charAt(0) || player.last_name?.charAt(0) || '?').toUpperCase();
    return (
        <div
            className="rounded-2xl flex items-center justify-center font-extrabold border-2 border-brand-gold/30"
            style={{
                width: dim,
                height: dim,
                backgroundColor: player.team?.primary_color ? `${player.team.primary_color}33` : 'rgba(214,143,3,0.15)',
                color: player.team?.primary_color || '#D68F03',
                fontSize,
            }}
        >
            {initial}
        </div>
    );
}

function TeamLogo({ team, size = 22 }: { team: TeamRef | null; size?: number }) {
    if (!team) return null;
    if (team.logo) {
        return (
            <img
                src={`/storage/${team.logo}`}
                alt={team.name}
                width={size}
                height={size}
                className="rounded-full object-cover"
                style={{ width: size, height: size }}
            />
        );
    }
    return (
        <div
            className="rounded-full flex items-center justify-center font-bold text-white"
            style={{
                width: size,
                height: size,
                backgroundColor: team.primary_color || '#D68F03',
                fontSize: size * 0.4,
            }}
        >
            {team.name.charAt(0)}
        </div>
    );
}

function StatCell({ value, label, color = 'default' }: { value: number; label: string; color?: 'default' | 'gold' | 'yellow' | 'blue' | 'red' }) {
    const colorClass = {
        default: 'text-white',
        gold: 'text-brand-gold',
        yellow: 'text-yellow-400',
        blue: 'text-blue-400',
        red: 'text-red-400',
    }[color];
    return (
        <div className="bg-white/[0.03] border border-white/10 rounded-lg py-2.5 text-center">
            <p className={`text-xl font-extrabold ${colorClass}`}>{value}</p>
            <p className="text-gray-500 text-[10px] uppercase tracking-wider mt-0.5">{label}</p>
        </div>
    );
}

function PlayerFullCard({ player }: { player: PlayerResult }) {
    const cfg = statusConfig[player.approval_status] ?? statusConfig.pending;
    const StatusIcon = cfg.icon;
    const positionLabel = player.position ? (positionLabels[player.position] ?? player.position) : null;

    return (
        <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
            className="bg-white/[0.03] border border-white/10 rounded-2xl overflow-hidden"
        >
            <div className="p-6 sm:p-8">
                <div className="flex flex-col sm:flex-row gap-6 items-center sm:items-start">
                    <div className="flex-shrink-0">
                        <PlayerPhoto player={player} size="lg" />
                    </div>
                    <div className="flex-1 min-w-0 text-center sm:text-left">
                        <div className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full ${cfg.bg} ${cfg.text} text-xs font-bold uppercase tracking-wider mb-3`}>
                            <StatusIcon className="w-4 h-4" />
                            <span>{cfg.label}</span>
                        </div>
                        <h2 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
                            {player.first_name} {player.last_name}
                            {player.is_captain && (
                                <span className="ml-2 inline-flex items-center justify-center w-6 h-6 rounded bg-brand-gold text-black text-xs font-extrabold align-middle">C</span>
                            )}
                        </h2>
                        {player.team && (
                            <div className="flex items-center gap-2 justify-center sm:justify-start mt-2">
                                <TeamLogo team={player.team} size={20} />
                                <span className="text-gray-300 font-semibold text-sm">{player.team.name}</span>
                            </div>
                        )}
                        <div className="flex flex-wrap items-center justify-center sm:justify-start gap-2 mt-3">
                            {player.jersey_number != null && (
                                <span className="inline-flex items-center justify-center px-2.5 py-1 rounded-lg bg-brand-gold/15 text-brand-gold font-bold text-sm">
                                    #{player.jersey_number}
                                </span>
                            )}
                            {positionLabel && (
                                <span className="inline-flex items-center px-2.5 py-1 rounded-lg bg-white/[0.04] border border-white/10 text-gray-300 text-xs font-semibold uppercase tracking-wider">
                                    {positionLabel}
                                </span>
                            )}
                            {player.unique_code && (
                                <span className="inline-flex items-center px-2.5 py-1 rounded-lg bg-white/[0.04] border border-white/10 text-gray-400 text-xs font-mono">
                                    {player.unique_code}
                                </span>
                            )}
                        </div>
                    </div>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 mt-7">
                    {player.document_number && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-3">
                            <p className="text-gray-500 text-[10px] uppercase tracking-wider">Documento</p>
                            <p className="text-white font-semibold text-sm mt-1">{player.document_type} {player.document_number}</p>
                        </div>
                    )}
                    {player.birth_date && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-3">
                            <p className="text-gray-500 text-[10px] uppercase tracking-wider">Nacimiento</p>
                            <p className="text-white font-semibold text-sm mt-1">
                                {new Date(player.birth_date).toLocaleDateString('es-CO', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' })}
                                {player.age != null && <span className="text-gray-500 font-normal"> · {player.age} años</span>}
                            </p>
                        </div>
                    )}
                    {player.blood_type && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-3">
                            <p className="text-gray-500 text-[10px] uppercase tracking-wider">Tipo de Sangre</p>
                            <p className="text-white font-semibold text-sm mt-1">
                                <span className="inline-flex items-center justify-center px-2 py-0.5 rounded bg-brand-gold/15 text-brand-gold font-bold">{player.blood_type}</span>
                            </p>
                        </div>
                    )}
                    {player.church && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-3">
                            <p className="text-gray-500 text-[10px] uppercase tracking-wider">Iglesia</p>
                            <p className="text-white font-semibold text-sm mt-1">{player.church}</p>
                        </div>
                    )}
                    {player.jersey_name && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-3">
                            <p className="text-gray-500 text-[10px] uppercase tracking-wider">Nombre en Dorsal</p>
                            <p className="text-white font-semibold text-sm mt-1">{player.jersey_name}</p>
                        </div>
                    )}
                </div>

                <div className="mt-6 pt-5 border-t border-white/10">
                    <p className="text-brand-gold text-[11px] font-bold uppercase tracking-[0.2em] text-center mb-3">Estadísticas</p>
                    <div className="grid grid-cols-5 gap-2">
                        <StatCell value={player.stats.goals} label="Goles" color="gold" />
                        <StatCell value={player.stats.matches} label="PJ" />
                        <StatCell value={player.stats.yellow_cards} label="TA" color="yellow" />
                        <StatCell value={player.stats.blue_cards} label="TAz" color="blue" />
                        <StatCell value={player.stats.red_cards} label="TR" color="red" />
                    </div>
                </div>
            </div>
        </motion.div>
    );
}

function PlayerMiniCard({ player }: { player: PlayerResult }) {
    const cfg = statusConfig[player.approval_status] ?? statusConfig.pending;
    const StatusIcon = cfg.icon;
    return (
        <Link
            href={`/verificar/${player.unique_code ?? ''}`}
            className="flex items-center gap-3 bg-white/[0.03] hover:bg-white/[0.06] border border-white/10 hover:border-brand-gold/40 rounded-xl p-3 transition group"
        >
            <PlayerPhoto player={player} size="md" />
            <div className="flex-1 min-w-0">
                <p className="text-white font-bold text-sm truncate">
                    {player.first_name} {player.last_name}
                </p>
                {player.team && (
                    <p className="text-gray-400 text-xs mt-0.5 truncate">{player.team.name}</p>
                )}
                <div className={`inline-flex items-center gap-1 px-2 py-0.5 rounded-full ${cfg.bg} ${cfg.text} text-[10px] font-bold uppercase tracking-wider mt-1.5`}>
                    <StatusIcon className="w-3 h-3" />
                    <span>{cfg.label}</span>
                </div>
            </div>
        </Link>
    );
}

export default function Verificar({ query = '', players = [], settings = {} }: Props) {
    const [input, setInput] = useState(query);
    const [showScanner, setShowScanner] = useState(false);
    const data = Array.isArray(players) ? players : [];

    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    const submit = (e: React.FormEvent) => {
        e.preventDefault();
        const q = input.trim();
        if (!q) return;
        router.get('/verificar', { q }, { preserveScroll: true });
    };

    // Procesa el resultado del scanner: maneja URL de validador,
    // codigos LDJ- directos y QRs legacy con JSON.
    const handleScanResult = (text: string) => {
        setShowScanner(false);
        if (!text) return;
        const trimmed = text.trim();

        // 1) URL completa con /verificar/{code}
        const urlMatch = trimmed.match(/\/verificar\/([A-Za-z0-9\-_]+)/i);
        if (urlMatch) {
            router.visit(`/verificar/${urlMatch[1]}`);
            return;
        }

        // 2) Codigo LDJ- plano
        if (/^LDJ-/i.test(trimmed)) {
            router.visit(`/verificar/${trimmed}`);
            return;
        }

        // 3) Carnet legacy con QR JSON: extraer "codigo" o "code"
        try {
            const parsed = JSON.parse(trimmed);
            const code = parsed?.codigo || parsed?.code;
            if (code) {
                router.visit(`/verificar/${code}`);
                return;
            }
        } catch {
            // no era JSON, sigue
        }

        // 4) Cualquier otra cosa: cargarlo en el input y buscar
        setInput(trimmed);
        router.get('/verificar', { q: trimmed });
    };

    return (
        <>
            <Head>
                <title>{`Validador de Jugadores - ${siteName}`}</title>
                <meta name="description" content={`Verifica el estado y la ficha de jugadores del ${siteName}.`} />
            </Head>

            <div className="bg-brand-black min-h-screen flex flex-col">
                <header className="bg-brand-black/95 backdrop-blur-sm border-b border-brand-gold/20">
                    <div className="max-w-5xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
                        <Link href="/" className="flex items-center gap-3">
                            {logoUrl
                                ? <img src={logoUrl} alt={siteName} className="h-10 w-10 object-contain" />
                                : <span className="text-brand-gold font-bold text-xl">LJ</span>
                            }
                            <span className="text-white font-bold text-base hidden sm:block">{siteName}</span>
                        </Link>
                        <Link href="/" className="hidden sm:flex text-gray-300 hover:text-brand-gold transition items-center gap-1.5 text-sm">
                            <ArrowLeft className="w-4 h-4" />
                            <span>Volver al inicio</span>
                        </Link>
                        <MobileSideDrawer />
                    </div>
                </header>

                <main className="flex-1 py-10 px-4">
                    <div className="max-w-3xl mx-auto">
                        <motion.div initial="hidden" animate="visible" variants={fadeUp} className="text-center mb-8">
                            <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-brand-gold/10 mb-4">
                                <ShieldCheck className="w-7 h-7 text-brand-gold" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">Validador de Jugadores</h1>
                            <p className="text-gray-400 mt-2 text-sm max-w-xl mx-auto">
                                Consulta el estado y la ficha completa de un jugador escaneando el QR de su carnet o buscando por código, documento o nombre.
                            </p>
                        </motion.div>

                        <form onSubmit={submit} className="mb-3">
                            <div className="flex flex-col sm:flex-row gap-2 bg-white/[0.03] border border-white/10 rounded-2xl p-2 focus-within:border-brand-gold/40 transition">
                                <div className="flex-1 flex items-center gap-2 px-3">
                                    <Search className="w-5 h-5 text-gray-500 flex-shrink-0" />
                                    <input
                                        type="search"
                                        value={input}
                                        onChange={(e) => setInput(e.target.value)}
                                        placeholder="Documento, nombre o código LDJ-..."
                                        className="flex-1 bg-transparent text-white placeholder-gray-600 text-sm py-2.5 focus:outline-none"
                                        autoFocus
                                    />
                                </div>
                                <button
                                    type="submit"
                                    className="bg-brand-gold hover:bg-brand-gold-light text-black font-bold px-5 py-2.5 rounded-xl transition text-sm flex items-center justify-center gap-2"
                                >
                                    <Search className="w-4 h-4 sm:hidden" />
                                    <span>Buscar</span>
                                </button>
                            </div>
                            <p className="text-gray-600 text-[11px] mt-2 px-2">
                                Busca por <span className="text-brand-gold">número de documento</span>, nombre, apellido o código del carnet (<span className="text-brand-gold font-mono">LDJ-...</span>).
                            </p>
                        </form>

                        <div className="flex items-center gap-3 my-5">
                            <span className="flex-1 h-px bg-white/10" />
                            <span className="text-gray-600 text-[10px] uppercase tracking-[0.3em] font-bold">o</span>
                            <span className="flex-1 h-px bg-white/10" />
                        </div>

                        <button
                            type="button"
                            onClick={() => setShowScanner(true)}
                            className="w-full mb-8 flex items-center justify-center gap-3 bg-brand-gold/10 hover:bg-brand-gold/20 border border-brand-gold/30 hover:border-brand-gold/60 text-brand-gold font-bold px-5 py-4 rounded-2xl transition text-sm"
                        >
                            <ScanLine className="w-5 h-5" />
                            <span>Escanear QR del carnet</span>
                        </button>

                        {query !== '' && data.length === 0 && (
                            <div className="text-center py-12 text-gray-500 bg-white/[0.02] border border-white/5 rounded-2xl">
                                <UserIcon className="w-12 h-12 mx-auto mb-3 opacity-30" />
                                <p className="font-semibold text-gray-400">No se encontró ningún jugador</p>
                                <p className="text-xs mt-1">para la búsqueda <span className="text-brand-gold font-mono">"{query}"</span></p>
                            </div>
                        )}

                        {data.length === 1 && (
                            <PlayerFullCard player={data[0]} />
                        )}

                        {data.length > 1 && (
                            <div>
                                <p className="text-gray-500 text-xs uppercase tracking-wider font-medium mb-3 px-1">
                                    {data.length} resultados — toca uno para ver la ficha completa
                                </p>
                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                                    {data.map((p) => (
                                        <PlayerMiniCard key={p.id} player={p} />
                                    ))}
                                </div>
                            </div>
                        )}

                        {query === '' && data.length === 0 && (
                            <div className="text-center py-10 text-gray-600 bg-white/[0.02] border border-white/5 rounded-2xl">
                                <ShieldCheck className="w-12 h-12 mx-auto mb-3 opacity-30" />
                                <p className="font-semibold text-gray-500">Comienza una búsqueda</p>
                                <p className="text-xs mt-1 max-w-sm mx-auto">Ingresa el código del carnet, número de documento o nombre del jugador a verificar.</p>
                            </div>
                        )}
                    </div>
                </main>

                <footer className="bg-brand-black border-t border-white/10 py-6 px-4">
                    <div className="max-w-5xl mx-auto text-center">
                        <p className="text-gray-600 text-xs">© {new Date().getFullYear()} {siteName}. Todos los derechos reservados.</p>
                    </div>
                </footer>

                <MobileBottomNav />

                <AnimatePresence>
                    {showScanner && (
                        <QrScannerOverlay
                            onClose={() => setShowScanner(false)}
                            onResult={handleScanResult}
                        />
                    )}
                </AnimatePresence>
            </div>
        </>
    );
}
