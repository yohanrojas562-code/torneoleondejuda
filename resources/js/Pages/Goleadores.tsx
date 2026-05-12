import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import { Target, ArrowLeft } from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

interface Tournament { id: number; name: string; logo: string | null; }
interface Season { id: number; name: string; status: string; tournament: Tournament; }
interface ScorerTeam { id: number; name: string; short_name: string | null; logo: string | null; primary_color: string | null; }
interface Scorer {
    id: number;
    first_name: string;
    last_name: string;
    photo: string | null;
    jersey_number: number | null;
    goals: number;
    team: ScorerTeam | null;
}

type Props = PageProps<{
    activeSeason: Season | null;
    topScorers: Scorer[];
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };

function PlayerPhoto({ scorer, size = 36 }: { scorer: Scorer; size?: number }) {
    if (scorer.photo) {
        return (
            <img
                src={`/storage/${scorer.photo}`}
                alt={`${scorer.first_name} ${scorer.last_name}`}
                width={size}
                height={size}
                className="rounded-full object-cover border border-white/10"
                style={{ width: size, height: size }}
            />
        );
    }
    const initial = (scorer.first_name?.charAt(0) || scorer.last_name?.charAt(0) || '?').toUpperCase();
    return (
        <div
            className="rounded-full flex items-center justify-center font-bold text-white border border-white/10"
            style={{
                width: size,
                height: size,
                backgroundColor: scorer.team?.primary_color || '#D68F03',
                fontSize: size * 0.4,
            }}
        >
            {initial}
        </div>
    );
}

function TeamLogo({ team, size = 22 }: { team: ScorerTeam | null; size?: number }) {
    if (!team) {
        return <div className="rounded-full bg-white/[0.04]" style={{ width: size, height: size }} />;
    }
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

function RankBadge({ position }: { position: number }) {
    const base = 'inline-flex items-center justify-center w-7 h-7 rounded text-xs font-extrabold';
    if (position === 1) return <span className={`${base} bg-brand-gold text-black`}>{position}</span>;
    if (position <= 3) return <span className={`${base} bg-brand-gold/15 text-brand-gold`}>{position}</span>;
    return <span className={`${base} text-gray-500`}>{position}</span>;
}

export default function Goleadores({ activeSeason, topScorers = [], settings = {} }: Props) {
    const scorers = Array.isArray(topScorers) ? topScorers : [];

    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    return (
        <>
            <Head>
                <title>{`Tabla de Goleadores - ${siteName}`}</title>
                <meta name="description" content={`Tabla de goleadores del ${siteName}${activeSeason ? ` - ${activeSeason.name}` : ''}`} />
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

                <main className="flex-1 py-12 px-4">
                    <div className="max-w-4xl mx-auto">
                        <motion.div initial="hidden" animate="visible" variants={fadeUp} className="text-center mb-10">
                            <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-brand-gold/10 mb-4">
                                <Target className="w-7 h-7 text-brand-gold" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">Tabla de Goleadores</h1>
                            {activeSeason && (
                                <p className="text-gray-400 mt-2 text-sm">
                                    {activeSeason.tournament?.name} · {activeSeason.name}
                                </p>
                            )}
                        </motion.div>

                        {scorers.length === 0 ? (
                            <div className="text-center py-20 text-gray-600">
                                <Target className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                <p className="text-sm">La tabla se actualizará cuando se anoten los primeros goles.</p>
                            </div>
                        ) : (
                            <motion.div initial="hidden" animate="visible" variants={fadeUp}>
                                <div className="overflow-x-auto rounded-xl border border-white/10">
                                    <table className="min-w-full text-sm">
                                        <thead>
                                            <tr className="bg-white/5 text-gray-500 text-[11px] uppercase tracking-wider">
                                                <th className="py-3 px-4 text-left w-12">#</th>
                                                <th className="py-3 px-3 text-left">Jugador</th>
                                                <th className="py-3 px-3 text-left">Equipo</th>
                                                <th className="py-3 px-3 text-center w-16">Dorsal</th>
                                                <th className="py-3 px-3 text-center font-bold text-white w-20">Goles</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {scorers.map((p, i) => (
                                                <tr
                                                    key={p.id}
                                                    className={`border-t border-white/5 hover:bg-white/[0.04] transition-colors ${i === 0 ? 'bg-brand-gold/[0.06]' : ''}`}
                                                >
                                                    <td className="py-3 px-4">
                                                        <RankBadge position={i + 1} />
                                                    </td>
                                                    <td className="py-3 px-3">
                                                        <div className="flex items-center gap-3 min-w-0">
                                                            <PlayerPhoto scorer={p} size={36} />
                                                            <span className="text-white font-medium text-sm whitespace-nowrap">
                                                                {p.first_name} {p.last_name}
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td className="py-3 px-3">
                                                        <div className="flex items-center gap-2 min-w-0">
                                                            <TeamLogo team={p.team} size={22} />
                                                            <span className="text-gray-400 text-sm whitespace-nowrap">
                                                                {p.team?.short_name || p.team?.name || '—'}
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td className="py-3 px-3 text-center text-gray-400">
                                                        {p.jersey_number ?? '—'}
                                                    </td>
                                                    <td className="py-3 px-3 text-center">
                                                        <span className="text-brand-gold font-extrabold text-lg">{p.goals}</span>
                                                    </td>
                                                </tr>
                                            ))}
                                        </tbody>
                                    </table>
                                </div>
                                <p className="text-gray-600 text-xs text-center mt-4">
                                    Total: {scorers.length} {scorers.length === 1 ? 'goleador' : 'goleadores'} · {scorers.reduce((s, p) => s + p.goals, 0)} {scorers.reduce((s, p) => s + p.goals, 0) === 1 ? 'gol' : 'goles'}
                                </p>
                            </motion.div>
                        )}
                    </div>
                </main>

                <footer className="bg-brand-black border-t border-white/10 py-6 px-4">
                    <div className="max-w-5xl mx-auto text-center">
                        <p className="text-gray-600 text-xs">© {new Date().getFullYear()} {siteName}. Todos los derechos reservados.</p>
                    </div>
                </footer>

                <MobileBottomNav />
            </div>
        </>
    );
}
