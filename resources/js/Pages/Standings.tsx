import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import { Trophy, ArrowLeft } from 'lucide-react';

interface Tournament { id: number; name: string; logo: string | null; }
interface Season { id: number; name: string; status: string; tournament: Tournament; }
interface Standing {
    id: number;
    team: { id: number; name: string; short_name: string | null; logo: string | null; primary_color?: string | null };
    group: { id: number; name: string } | null;
    played: number; won: number; drawn: number; lost: number;
    goals_for: number; goals_against: number; goal_difference: number;
    points: number; position: number;
    yellow_cards: number; blue_cards: number; red_cards: number;
    fair_play_points: number;
}

type Props = PageProps<{
    activeSeason: Season | null;
    standings: Standing[];
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };

function TeamLogo({ team, size = 40 }: { team: { logo: string | null; name: string; primary_color?: string | null }; size?: number }) {
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
            style={{ width: size, height: size, backgroundColor: team.primary_color || '#D68F03', fontSize: size * 0.35 }}
        >
            {team.name.charAt(0)}
        </div>
    );
}

export default function Standings({ activeSeason, standings = [], settings = {} }: Props) {
    const standingsData = Array.isArray(standings) ? standings : [];

    const standingsGrouped: Record<string, Standing[]> = {};
    standingsData.forEach((s) => {
        const g = s.group?.name || 'General';
        if (!standingsGrouped[g]) standingsGrouped[g] = [];
        standingsGrouped[g].push(s);
    });

    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    return (
        <>
            <Head>
                <title>{`Tabla de Posiciones - ${siteName}`}</title>
                <meta name="description" content={`Tabla de posiciones del ${siteName}${activeSeason ? ` - ${activeSeason.name}` : ''}`} />
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
                        <Link
                            href="/"
                            className="text-gray-300 hover:text-brand-gold transition flex items-center gap-1.5 text-sm"
                        >
                            <ArrowLeft className="w-4 h-4" />
                            <span className="hidden sm:inline">Volver al inicio</span>
                            <span className="sm:hidden">Inicio</span>
                        </Link>
                    </div>
                </header>

                <main className="flex-1 py-12 px-4">
                    <div className="max-w-5xl mx-auto">
                        <motion.div initial="hidden" animate="visible" variants={fadeUp} className="text-center mb-10">
                            <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-brand-gold/10 mb-4">
                                <Trophy className="w-7 h-7 text-brand-gold" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">Tabla de Posiciones</h1>
                            {activeSeason && (
                                <p className="text-gray-400 mt-2 text-sm">
                                    {activeSeason.tournament?.name} · {activeSeason.name}
                                </p>
                            )}
                        </motion.div>

                        {standingsData.length === 0 ? (
                            <div className="text-center py-20 text-gray-600">
                                <Trophy className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                <p className="text-sm">La tabla se actualizará cuando haya partidos finalizados.</p>
                            </div>
                        ) : (
                            <div className="space-y-8">
                                {Object.entries(standingsGrouped).map(([groupName, rows]) => (
                                    <div key={groupName}>
                                        {Object.keys(standingsGrouped).length > 1 && (
                                            <h3 className="text-brand-gold font-semibold text-xs uppercase tracking-wider mb-3">{groupName}</h3>
                                        )}
                                        <div className="overflow-x-auto rounded-xl border border-white/10">
                                            <table className="min-w-full text-sm">
                                                <thead>
                                                    <tr className="bg-white/5 text-gray-500 text-[11px] uppercase tracking-wider">
                                                        <th className="py-3 px-4 text-left w-10">#</th>
                                                        <th className="py-3 px-3 text-left">Equipo</th>
                                                        <th className="py-3 px-3 text-center">PJ</th>
                                                        <th className="py-3 px-3 text-center">G</th>
                                                        <th className="py-3 px-3 text-center">E</th>
                                                        <th className="py-3 px-3 text-center">P</th>
                                                        <th className="py-3 px-3 text-center">GF</th>
                                                        <th className="py-3 px-3 text-center">GC</th>
                                                        <th className="py-3 px-3 text-center">DG</th>
                                                        <th className="py-3 px-3 text-center" title="Fair Play (amarilla -1, azul -3, roja -5)">FP</th>
                                                        <th className="py-3 px-3 text-center font-bold text-white">PTS</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    {rows.map((s, i) => (
                                                        <tr
                                                            key={s.id}
                                                            className={`border-t border-white/5 hover:bg-white/[0.04] transition-colors ${i === 0 ? 'bg-brand-gold/[0.06]' : ''}`}
                                                        >
                                                            <td className="py-3 px-4">
                                                                <span className={`inline-flex items-center justify-center w-6 h-6 rounded text-xs font-bold ${
                                                                    i === 0 ? 'bg-brand-gold text-black' : i < 3 ? 'text-brand-gold' : 'text-gray-600'
                                                                }`}>{i + 1}</span>
                                                            </td>
                                                            <td className="py-3 px-3">
                                                                <div className="flex items-center gap-2">
                                                                    <TeamLogo team={s.team} size={22} />
                                                                    <span className="text-white font-medium text-sm whitespace-nowrap">{s.team.name}</span>
                                                                </div>
                                                            </td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.played}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.won}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.drawn}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.lost}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.goals_for}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.goals_against}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.goal_difference}</td>
                                                            <td className="py-3 px-3 text-center">
                                                                <span className={(s.fair_play_points ?? 0) < 0 ? 'text-red-400' : 'text-gray-400'}>{s.fair_play_points ?? 0}</span>
                                                            </td>
                                                            <td className="py-3 px-3 text-center text-white font-extrabold">{s.points}</td>
                                                        </tr>
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </main>

                <footer className="bg-brand-black border-t border-white/10 py-6 px-4">
                    <div className="max-w-5xl mx-auto text-center">
                        <p className="text-gray-600 text-xs">
                            © {new Date().getFullYear()} {siteName}. Todos los derechos reservados.
                        </p>
                    </div>
                </footer>
            </div>
        </>
    );
}
