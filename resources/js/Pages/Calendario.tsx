import { useState } from 'react';
import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import { Calendar, ArrowLeft, MapPin, Clock, AlertTriangle, CheckCircle2 } from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

interface Tournament { id: number; name: string; logo: string | null; }
interface Season { id: number; name: string; status: string; tournament: Tournament; }
interface MatchTeam { id: number; name: string; short_name: string | null; logo: string | null; primary_color?: string | null; }
interface MatchEvent {
    id: number;
    type: 'goal' | 'own_goal' | 'penalty_goal' | 'yellow_card' | 'red_card' | 'second_yellow' | 'blue_card';
    minute: number;
    team_id: number;
    player: { id: number; first_name: string; last_name: string; jersey_number: number | null } | null;
}
interface GameMatch {
    id: number;
    home_team: MatchTeam;
    away_team: MatchTeam;
    home_team_id: number;
    away_team_id: number;
    home_score: number | null;
    away_score: number | null;
    home_yellow_cards?: number;
    home_blue_cards?: number;
    home_red_cards?: number;
    away_yellow_cards?: number;
    away_blue_cards?: number;
    away_red_cards?: number;
    scheduled_at: string;
    status: string;
    venue: { id: number; name: string } | null;
    match_day: { id: number; name: string } | null;
    events?: MatchEvent[];
}

type Props = PageProps<{
    activeSeason: Season | null;
    upcomingMatches: GameMatch[];
    finishedMatches: GameMatch[];
    postponedMatches: GameMatch[];
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };

function formatDateLong(d: string) {
    return new Date(d).toLocaleDateString('es-CO', { weekday: 'long', day: 'numeric', month: 'long', timeZone: 'UTC' });
}
function formatTime(d: string) {
    return new Date(d).toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit', timeZone: 'UTC' });
}
function statusLabel(s: string) {
    const map: Record<string, string> = {
        scheduled: 'Programado', warmup: 'Calentando', first_half: '1er Tiempo',
        halftime: 'Descanso', second_half: '2do Tiempo', extra_time: 'Prórroga',
        penalties: 'Penales', finished: 'Finalizado', suspended: 'Suspendido',
        cancelled: 'Cancelado', postponed: 'Aplazado',
    };
    return map[s] || s;
}

function TeamLogo({ team, size = 40 }: { team: MatchTeam; size?: number }) {
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

function groupByDate(matches: GameMatch[]) {
    const groups: Record<string, GameMatch[]> = {};
    matches.forEach(m => {
        const key = formatDateLong(m.scheduled_at);
        if (!groups[key]) groups[key] = [];
        groups[key].push(m);
    });
    return groups;
}

function UpcomingMatchCard({ match }: { match: GameMatch }) {
    const isLive = ['first_half', 'halftime', 'second_half', 'extra_time', 'penalties', 'warmup'].includes(match.status);
    return (
        <div className={`bg-white/[0.03] border border-white/5 rounded-xl p-4 ${isLive ? 'ring-1 ring-green-500/50' : ''}`}>
            {match.match_day && (
                <p className="text-gray-500 text-[10px] uppercase tracking-wider font-medium mb-2">{match.match_day.name}</p>
            )}
            <div className="flex items-center gap-3">
                <div className="flex-1 flex items-center justify-end gap-2 min-w-0">
                    <span className="text-white text-sm font-medium truncate text-right">{match.home_team.name}</span>
                    <TeamLogo team={match.home_team} size={32} />
                </div>
                <div className="flex-shrink-0 w-20 text-center">
                    {isLive ? (
                        <>
                            <div className="flex items-center justify-center gap-1 text-green-400 font-extrabold text-lg">
                                <span>{match.home_score ?? 0}</span>
                                <span className="text-gray-600 font-normal mx-0.5">-</span>
                                <span>{match.away_score ?? 0}</span>
                            </div>
                            <div className="flex items-center justify-center gap-1 mt-0.5">
                                <span className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" />
                                <span className="text-green-400 text-[9px] font-bold uppercase">{statusLabel(match.status)}</span>
                            </div>
                        </>
                    ) : (
                        <>
                            <p className="text-brand-gold font-bold text-base">{formatTime(match.scheduled_at)}</p>
                            <p className="text-gray-600 text-[10px]">Próximo</p>
                        </>
                    )}
                </div>
                <div className="flex-1 flex items-center gap-2 min-w-0">
                    <TeamLogo team={match.away_team} size={32} />
                    <span className="text-white text-sm font-medium truncate">{match.away_team.name}</span>
                </div>
            </div>
            {match.venue && (
                <div className="mt-3 pt-3 border-t border-white/5 flex items-center gap-1.5 text-gray-500 text-xs">
                    <MapPin className="w-3 h-3" />
                    <span>{match.venue.name}</span>
                </div>
            )}
        </div>
    );
}

function FinishedMatchCard({ match }: { match: GameMatch }) {
    const events = match.events || [];
    const homeGoals = events.filter(e => e.team_id === match.home_team_id && (e.type === 'goal' || e.type === 'penalty_goal' || e.type === 'own_goal'));
    const awayGoals = events.filter(e => e.team_id === match.away_team_id && (e.type === 'goal' || e.type === 'penalty_goal' || e.type === 'own_goal'));

    const homeYellow = match.home_yellow_cards ?? 0;
    const homeBlue = match.home_blue_cards ?? 0;
    const homeRed = match.home_red_cards ?? 0;
    const awayYellow = match.away_yellow_cards ?? 0;
    const awayBlue = match.away_blue_cards ?? 0;
    const awayRed = match.away_red_cards ?? 0;

    const playerName = (e: MatchEvent) => {
        if (!e.player) return 'Auto-gol';
        return `${e.player.first_name} ${e.player.last_name.charAt(0)}.`;
    };

    return (
        <div className="bg-white/[0.03] border border-white/5 rounded-xl p-4">
            <div className="flex items-center justify-between mb-3">
                {match.match_day && (
                    <p className="text-gray-500 text-[10px] uppercase tracking-wider font-medium">{match.match_day.name}</p>
                )}
                <span className="inline-flex items-center gap-1 text-gray-500 text-[10px]">
                    <CheckCircle2 className="w-3 h-3" /> Finalizado
                </span>
            </div>

            <div className="flex items-center gap-3">
                <div className="flex-1 flex items-center justify-end gap-2 min-w-0">
                    <span className="text-white text-sm font-semibold truncate text-right">{match.home_team.name}</span>
                    <TeamLogo team={match.home_team} size={36} />
                </div>
                <div className="flex-shrink-0 px-3">
                    <div className="flex items-center gap-2 font-extrabold text-2xl text-white">
                        <span>{match.home_score ?? 0}</span>
                        <span className="text-gray-600 font-normal text-base">-</span>
                        <span>{match.away_score ?? 0}</span>
                    </div>
                </div>
                <div className="flex-1 flex items-center gap-2 min-w-0">
                    <TeamLogo team={match.away_team} size={36} />
                    <span className="text-white text-sm font-semibold truncate">{match.away_team.name}</span>
                </div>
            </div>

            {(homeGoals.length > 0 || awayGoals.length > 0) && (
                <div className="grid grid-cols-2 gap-3 mt-4 pt-4 border-t border-white/5">
                    <div className="space-y-1">
                        {homeGoals.map(e => (
                            <div key={e.id} className="flex items-center gap-1.5 text-xs text-gray-400">
                                <span className="text-brand-gold">⚽</span>
                                <span className="truncate">{playerName(e)}</span>
                                <span className="text-gray-600 text-[10px]">{e.minute}'</span>
                                {e.type === 'penalty_goal' && <span className="text-[9px] text-gray-600">(P)</span>}
                                {e.type === 'own_goal' && <span className="text-[9px] text-red-400">(AG)</span>}
                            </div>
                        ))}
                    </div>
                    <div className="space-y-1">
                        {awayGoals.map(e => (
                            <div key={e.id} className="flex items-center gap-1.5 text-xs text-gray-400">
                                <span className="text-brand-gold">⚽</span>
                                <span className="truncate">{playerName(e)}</span>
                                <span className="text-gray-600 text-[10px]">{e.minute}'</span>
                                {e.type === 'penalty_goal' && <span className="text-[9px] text-gray-600">(P)</span>}
                                {e.type === 'own_goal' && <span className="text-[9px] text-red-400">(AG)</span>}
                            </div>
                        ))}
                    </div>
                </div>
            )}

            {(homeYellow + homeBlue + homeRed + awayYellow + awayBlue + awayRed) > 0 && (
                <div className="grid grid-cols-2 gap-3 mt-3 pt-3 border-t border-white/5">
                    <div className="flex items-center gap-2 text-[10px]">
                        {homeYellow > 0 && (
                            <span className="inline-flex items-center gap-1 text-yellow-400">
                                <span className="w-2 h-2.5 bg-yellow-400 rounded-sm" />{homeYellow}
                            </span>
                        )}
                        {homeBlue > 0 && (
                            <span className="inline-flex items-center gap-1 text-blue-400">
                                <span className="w-2 h-2.5 bg-blue-400 rounded-sm" />{homeBlue}
                            </span>
                        )}
                        {homeRed > 0 && (
                            <span className="inline-flex items-center gap-1 text-red-500">
                                <span className="w-2 h-2.5 bg-red-500 rounded-sm" />{homeRed}
                            </span>
                        )}
                    </div>
                    <div className="flex items-center gap-2 text-[10px]">
                        {awayYellow > 0 && (
                            <span className="inline-flex items-center gap-1 text-yellow-400">
                                <span className="w-2 h-2.5 bg-yellow-400 rounded-sm" />{awayYellow}
                            </span>
                        )}
                        {awayBlue > 0 && (
                            <span className="inline-flex items-center gap-1 text-blue-400">
                                <span className="w-2 h-2.5 bg-blue-400 rounded-sm" />{awayBlue}
                            </span>
                        )}
                        {awayRed > 0 && (
                            <span className="inline-flex items-center gap-1 text-red-500">
                                <span className="w-2 h-2.5 bg-red-500 rounded-sm" />{awayRed}
                            </span>
                        )}
                    </div>
                </div>
            )}

            <div className="mt-3 pt-3 border-t border-white/5 flex items-center justify-between gap-2 text-[10px] text-gray-600">
                <span className="flex items-center gap-1">
                    <Clock className="w-3 h-3" /> {formatTime(match.scheduled_at)}
                </span>
                {match.venue && (
                    <span className="flex items-center gap-1 truncate">
                        <MapPin className="w-3 h-3" /> {match.venue.name}
                    </span>
                )}
            </div>
        </div>
    );
}

function PostponedMatchCard({ match }: { match: GameMatch }) {
    return (
        <div className="bg-white/[0.03] border border-red-500/20 rounded-xl p-4">
            <div className="flex items-center justify-between mb-3">
                {match.match_day && (
                    <p className="text-gray-500 text-[10px] uppercase tracking-wider font-medium">{match.match_day.name}</p>
                )}
                <span className="inline-flex items-center gap-1 text-red-400 text-[10px] font-bold uppercase">
                    <AlertTriangle className="w-3 h-3" /> {statusLabel(match.status)}
                </span>
            </div>
            <div className="flex items-center gap-3">
                <div className="flex-1 flex items-center justify-end gap-2 min-w-0">
                    <span className="text-white text-sm font-medium truncate text-right">{match.home_team.name}</span>
                    <TeamLogo team={match.home_team} size={32} />
                </div>
                <span className="text-gray-600 text-base font-bold">vs</span>
                <div className="flex-1 flex items-center gap-2 min-w-0">
                    <TeamLogo team={match.away_team} size={32} />
                    <span className="text-white text-sm font-medium truncate">{match.away_team.name}</span>
                </div>
            </div>
            {match.venue && (
                <div className="mt-3 pt-3 border-t border-white/5 flex items-center gap-1.5 text-gray-500 text-xs">
                    <MapPin className="w-3 h-3" />
                    <span>{match.venue.name}</span>
                </div>
            )}
        </div>
    );
}

export default function Calendario({ activeSeason, upcomingMatches = [], finishedMatches = [], postponedMatches = [], settings = {} }: Props) {
    const [tab, setTab] = useState<'proximos' | 'finalizados' | 'aplazados'>('proximos');

    const upcoming = Array.isArray(upcomingMatches) ? upcomingMatches : [];
    const finished = Array.isArray(finishedMatches) ? finishedMatches : [];
    const postponed = Array.isArray(postponedMatches) ? postponedMatches : [];

    const upcomingGrouped = groupByDate(upcoming);
    const finishedGrouped = groupByDate(finished);
    const postponedGrouped = groupByDate(postponed);

    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    return (
        <>
            <Head>
                <title>{`Calendario - ${siteName}`}</title>
                <meta name="description" content={`Calendario de partidos del ${siteName}${activeSeason ? ` - ${activeSeason.name}` : ''}`} />
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
                                <Calendar className="w-7 h-7 text-brand-gold" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">Calendario</h1>
                            {activeSeason && (
                                <p className="text-gray-400 mt-2 text-sm">
                                    {activeSeason.tournament?.name} · {activeSeason.name}
                                </p>
                            )}
                        </motion.div>

                        <div className="flex border-b border-white/10 mb-6 overflow-x-auto">
                            <button
                                onClick={() => setTab('proximos')}
                                className={`flex-shrink-0 px-5 py-3 text-sm font-semibold border-b-2 -mb-px transition-colors ${
                                    tab === 'proximos' ? 'text-brand-gold border-brand-gold' : 'text-gray-500 border-transparent hover:text-gray-200'
                                }`}
                            >
                                Próximos {upcoming.length > 0 && <span className="ml-1 text-xs opacity-70">({upcoming.length})</span>}
                            </button>
                            <button
                                onClick={() => setTab('finalizados')}
                                className={`flex-shrink-0 px-5 py-3 text-sm font-semibold border-b-2 -mb-px transition-colors ${
                                    tab === 'finalizados' ? 'text-brand-gold border-brand-gold' : 'text-gray-500 border-transparent hover:text-gray-200'
                                }`}
                            >
                                Finalizados {finished.length > 0 && <span className="ml-1 text-xs opacity-70">({finished.length})</span>}
                            </button>
                            <button
                                onClick={() => setTab('aplazados')}
                                className={`flex-shrink-0 px-5 py-3 text-sm font-semibold border-b-2 -mb-px transition-colors ${
                                    tab === 'aplazados' ? 'text-brand-gold border-brand-gold' : 'text-gray-500 border-transparent hover:text-gray-200'
                                }`}
                            >
                                Aplazados {postponed.length > 0 && <span className="ml-1 text-xs opacity-70">({postponed.length})</span>}
                            </button>
                        </div>

                        {tab === 'proximos' && (
                            <motion.div key="proximos" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.25 }}>
                                {upcoming.length === 0 ? (
                                    <div className="text-center py-20 text-gray-600">
                                        <Calendar className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                        <p className="text-sm">No hay próximos partidos programados.</p>
                                    </div>
                                ) : (
                                    <div className="space-y-6">
                                        {Object.entries(upcomingGrouped).map(([date, matches]) => (
                                            <div key={date}>
                                                <p className="text-gray-500 text-xs uppercase tracking-wider font-medium px-1 pb-3 capitalize">{date}</p>
                                                <div className="space-y-3">
                                                    {matches.map(m => <UpcomingMatchCard key={m.id} match={m} />)}
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </motion.div>
                        )}

                        {tab === 'finalizados' && (
                            <motion.div key="finalizados" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.25 }}>
                                {finished.length === 0 ? (
                                    <div className="text-center py-20 text-gray-600">
                                        <CheckCircle2 className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                        <p className="text-sm">Aún no hay partidos finalizados.</p>
                                    </div>
                                ) : (
                                    <div className="space-y-6">
                                        {Object.entries(finishedGrouped).map(([date, matches]) => (
                                            <div key={date}>
                                                <p className="text-gray-500 text-xs uppercase tracking-wider font-medium px-1 pb-3 capitalize">{date}</p>
                                                <div className="space-y-3">
                                                    {matches.map(m => <FinishedMatchCard key={m.id} match={m} />)}
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                )}
                            </motion.div>
                        )}

                        {tab === 'aplazados' && (
                            <motion.div key="aplazados" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.25 }}>
                                {postponed.length === 0 ? (
                                    <div className="text-center py-20 text-gray-600">
                                        <AlertTriangle className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                        <p className="text-sm">No hay partidos aplazados, suspendidos o cancelados.</p>
                                    </div>
                                ) : (
                                    <div className="space-y-6">
                                        {Object.entries(postponedGrouped).map(([date, matches]) => (
                                            <div key={date}>
                                                <p className="text-gray-500 text-xs uppercase tracking-wider font-medium px-1 pb-3 capitalize">{date}</p>
                                                <div className="space-y-3">
                                                    {matches.map(m => <PostponedMatchCard key={m.id} match={m} />)}
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                )}
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
