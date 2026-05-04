import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import { Trophy, ArrowLeft } from 'lucide-react';

interface Tournament { id: number; name: string; logo: string | null; banner: string | null; description: string | null; }
interface Season { id: number; name: string; status: string; start_date: string; end_date: string; tournament: Tournament; }
interface Standing { id: number; team: { id: number; name: string; short_name: string | null; logo: string | null }; group: { id: number; name: string } | null; played: number; won: number; drawn: number; lost: number; goals_for: number; goals_against: number; goal_difference: number; points: number; position: number; yellow_cards: number; blue_cards: number; red_cards: number; fair_play_points: number; }

type Props = PageProps<{
    activeSeason: Season | null;
    standings: Standing[];
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };
const stagger = { visible: { transition: { staggerChildren: 0.08 } } };

function formatDate(d: string) {
    return new Date(d).toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC' });
}

function TeamLogo({ team, size = 40 }: { team: { logo: string | null; name: string; primary_color?: string | null }; size?: number }) {
    if (team.logo) return <img src={`/storage/${team.logo}`} alt={team.name} width={size} height={size} className="rounded-full object-cover" style={{ width: size, height: size }} />;
    return (
        <div className="rounded-full flex items-center justify-center font-bold text-white" style={{ width: size, height: size, backgroundColor: team.primary_color || '#D68F03', fontSize: size * 0.35 }}>
            {team.name.charAt(0)}
        </div>
    );
}

export default function Standings({ activeSeason, standings = [], settings = {} }: Props) {
    const standingsData = Array.isArray(standings) ? standings : [];
    const standingsGrouped: Record<string, Standing[]> = {};
    
    standingsData.forEach((s: Standing) => {
        try {
            const g = s?.group?.name || 'General';
            if (!standingsGrouped[g]) standingsGrouped[g] = [];
            standingsGrouped[g].push(s);
        } catch (e) {
            console.error('Error processing standing:', s, e);
        }
    });

    return (
        <>
            <Head>
                <title>Tabla de Posiciones - {settings.site_name || 'Torneo León de Judá'}</title>
            </Head>
            <div className="bg-brand-black min-h-screen">
                {/* Header */}
                <div className="fixed top-0 left-0 right-0 z-40 bg-brand-black/95 backdrop-blur-sm border-b border-brand-gold/20">
                    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between h-16">
                        <Link href="/" className="flex items-center gap-2 hover:text-brand-gold transition text-gray-300">
                            <ArrowLeft className="w-4 h-4" />
                            <span className="text-sm">Volver</span>
                        </Link>
                        <div className="flex items-center gap-3">
                            <Trophy className="w-6 h-6 text-brand-gold" />
                            <h1 className="text-white font-bold text-xl">Tabla de Posiciones</h1>
                        </div>
                        <div className="w-24"></div>
                    </div>
                </div>

                {/* Main Content */}
                <div className="pt-24 pb-20 px-4">
                    <div className="max-w-5xl mx-auto">
                        {/* Info Section */}
                        {activeSeason && (
                            <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="text-center mb-12">
                                <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Temporada Activa</span>
                                <h2 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">{activeSeason.tournament.name}</h2>
                                <p className="text-gray-400 mt-2">{activeSeason.name} · {formatDate(activeSeason.start_date)} — {formatDate(activeSeason.end_date)}</p>
                            </motion.div>
                        )}

                        {/* Empty State */}
                        {standings.length === 0 ? (
                            <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="text-center py-20">
                                <Trophy className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                <p className="text-gray-600">La tabla se actualizará cuando haya partidos finalizados.</p>
                            </motion.div>
                        ) : (
                            <motion.div variants={stagger} initial="hidden" whileInView="visible" viewport={{ once: true, margin: '-50px' }} className="space-y-8">
                                {Object.entries(standingsGrouped).map(([groupName, rows]) => (
                                    <motion.div key={groupName} variants={fadeUp}>
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
                                                        <tr key={s.id} className={`border-t border-white/5 hover:bg-white/[0.04] transition-colors ${i === 0 ? 'bg-brand-gold/[0.06]' : ''}`}>
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
                                    </motion.div>
                                ))}
                            </motion.div>
                        )}
                    </div>
                </div>
            </div>
        </>
    );
}
