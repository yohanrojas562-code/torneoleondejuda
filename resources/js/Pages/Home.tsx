import { useState } from 'react';
import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import {
    Trophy, Users, MapPin, Calendar, Shield, ChevronRight,
    Clock, Star, Swords, ArrowRight, LogIn, UserPlus
} from 'lucide-react';

/* ───── types ───── */
interface Tournament { id: number; name: string; logo: string | null; banner: string | null; description: string | null; }
interface Season { id: number; name: string; status: string; start_date: string; end_date: string; tournament: Tournament; }
interface Team { id: number; name: string; short_name: string | null; logo: string | null; primary_color: string | null; secondary_color: string | null; players_count: number; }
interface Standing { id: number; team: { id: number; name: string; short_name: string | null; logo: string | null }; group: { id: number; name: string } | null; played: number; won: number; drawn: number; lost: number; goals_for: number; goals_against: number; goal_difference: number; points: number; position: number; yellow_cards: number; blue_cards: number; red_cards: number; }
interface MatchTeam { id: number; name: string; short_name: string | null; logo: string | null; }
interface GameMatch { id: number; home_team: MatchTeam; away_team: MatchTeam; home_score: number | null; away_score: number | null; scheduled_at: string; status: string; venue: { id: number; name: string } | null; match_day: { id: number; name: string } | null; }
interface Venue { id: number; name: string; address: string | null; city: string | null; image: string | null; surface_type: string | null; capacity: number | null; }

type Props = PageProps<{
    activeSeason: Season | null;
    teams: Team[];
    standings: Standing[];
    upcomingMatches: GameMatch[];
    recentMatches: GameMatch[];
    venues: Venue[];
    settings: Record<string, string | null>;
    canLogin: boolean;
    canRegister: boolean;
}>;

/* ───── helpers ───── */
const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };
const stagger = { visible: { transition: { staggerChildren: 0.08 } } };

function formatDate(d: string) {
    return new Date(d).toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC' });
}
function formatDateTime(d: string) {
    return new Date(d).toLocaleString('es-CO', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit', timeZone: 'UTC' });
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
function statusColor(s: string) {
    const liveStatuses = ['first_half', 'halftime', 'second_half', 'extra_time', 'penalties', 'warmup'];
    if (liveStatuses.includes(s)) return 'bg-green-500';
    const map: Record<string, string> = { scheduled: 'bg-blue-500', finished: 'bg-gray-500', suspended: 'bg-red-500', cancelled: 'bg-red-700', postponed: 'bg-yellow-600' };
    return map[s] || 'bg-gray-500';
}

function TeamLogo({ team, size = 40 }: { team: { logo: string | null; name: string; primary_color?: string | null }; size?: number }) {
    if (team.logo) return <img src={`/storage/${team.logo}`} alt={team.name} width={size} height={size} className="rounded-full object-cover" style={{ width: size, height: size }} />;
    return (
        <div className="rounded-full flex items-center justify-center font-bold text-white" style={{ width: size, height: size, backgroundColor: team.primary_color || '#D68F03', fontSize: size * 0.35 }}>
            {team.name.charAt(0)}
        </div>
    );
}

/* ───── sections ───── */

function Navbar({ canLogin, canRegister, auth, settings }: { canLogin: boolean; canRegister: boolean; auth: { user: any }; settings: Record<string, string | null> }) {
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;
    return (
        <nav className="fixed top-0 left-0 right-0 z-50 bg-brand-black/95 backdrop-blur-sm border-b border-brand-gold/20">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between h-16">
                <Link href="/" className="flex items-center gap-3">
                    {logoUrl
                        ? <img src={logoUrl} alt="León de Judá" className="h-10 w-10 object-contain" />
                        : <span className="text-brand-gold font-bold text-xl">LJ</span>
                    }
                    <span className="text-white font-bold text-lg hidden sm:block">León de Judá</span>
                </Link>
                <div className="hidden md:flex items-center gap-6 text-sm">
                    <a href="#torneo" className="text-gray-300 hover:text-brand-gold transition">Torneo</a>
                    <a href="#equipos" className="text-gray-300 hover:text-brand-gold transition">Equipos</a>
                    <a href="#partidos" className="text-gray-300 hover:text-brand-gold transition">Partidos</a>
                    <a href="#posiciones" className="text-gray-300 hover:text-brand-gold transition">Posiciones</a>
                    <a href="#escenarios" className="text-gray-300 hover:text-brand-gold transition">Escenarios</a>
                </div>
                <div className="flex items-center gap-2">
                    {auth.user ? (
                        <a href="/admin" className="bg-brand-gold hover:bg-brand-gold-light text-black font-semibold px-4 py-2 rounded-lg text-sm transition">
                            Panel <ArrowRight className="inline w-4 h-4 ml-1" />
                        </a>
                    ) : (
                        <>
                            {canLogin && (
                                <a href="/admin/login" className="bg-brand-gold hover:bg-brand-gold-light text-black font-semibold px-4 py-2 rounded-lg text-sm flex items-center gap-1 transition">
                                    <LogIn className="w-4 h-4" /> Ingresar
                                </a>
                            )}
                        </>
                    )}
                </div>
            </div>
        </nav>
    );
}

function Hero({ settings, activeSeason }: { settings: Record<string, string | null>; activeSeason: Season | null }) {
    return (
        <section className="relative min-h-[90vh] flex items-center justify-center overflow-hidden bg-brand-black">
            {/* Background pattern */}
            <div className="absolute inset-0 opacity-10">
                <div className="absolute inset-0" style={{ backgroundImage: 'radial-gradient(circle at 25% 50%, #D68F03 1px, transparent 1px)', backgroundSize: '50px 50px' }} />
            </div>
            <div className="absolute top-0 left-0 w-full h-full bg-gradient-to-b from-brand-black via-brand-black/90 to-brand-black" />

            <div className="relative z-10 text-center px-4 max-w-4xl mx-auto pt-24">
                <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.6 }}>
                    {settings.logo
                        ? <img src={`/storage/${settings.logo}`} alt="León de Judá" className="w-32 h-32 sm:w-40 sm:h-40 mx-auto mb-6 object-contain drop-shadow-[0_0_30px_rgba(214,143,3,0.3)]" />
                        : <div className="w-32 h-32 sm:w-40 sm:h-40 mx-auto mb-6 flex items-center justify-center"><span className="text-brand-gold font-extrabold text-6xl">LJ</span></div>
                    }
                </motion.div>

                <motion.h1 initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2, duration: 0.6 }}
                    className="text-4xl sm:text-5xl md:text-7xl font-extrabold text-white mb-4 tracking-tight">
                    {settings.home_title || 'Torneo León de Judá'}
                </motion.h1>

                <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4, duration: 0.6 }}
                    className="text-brand-gold text-lg sm:text-xl md:text-2xl font-medium mb-6">
                    {settings.home_subtitle || 'Mostrando a Cristo a través del deporte'}
                </motion.p>

                <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5, duration: 0.6 }}
                    className="text-gray-400 text-sm sm:text-base max-w-2xl mx-auto mb-8 leading-relaxed">
                    {settings.site_description || '¿Buscas un torneo de fútbol de salón en Medellín? Participa en nuestra copa de microfútbol diseñada para unir a la comunidad a través del deporte y los valores cristianos. Disfruta de una competencia organizada con el mejor talento local, promoviendo el juego limpio y la integración.'}
                </motion.p>

                {activeSeason && (
                    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.6, duration: 0.6 }}
                        className="inline-flex items-center gap-3 bg-white/5 border border-brand-gold/30 rounded-xl px-6 py-3 mb-8">
                        <Trophy className="w-5 h-5 text-brand-gold" />
                        <div className="text-left">
                            <p className="text-white font-semibold text-sm">{activeSeason.tournament.name}</p>
                            <p className="text-gray-400 text-xs">{activeSeason.name} · <span className={`inline-block w-2 h-2 rounded-full ${statusColor(activeSeason.status)} mr-1`} />{statusLabel(activeSeason.status)}</p>
                        </div>
                    </motion.div>
                )}


            </div>

            {/* Decorative bottom gradient */}
            <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-[#0d0d0d] to-transparent" />
        </section>
    );
}

function ValuesSection() {
    const values = [
        { icon: <Star className="w-8 h-8" />, title: 'Fe en Cristo', desc: 'Cada jugada es un testimonio de nuestra fe y compromiso con los valores del Evangelio.' },
        { icon: <Users className="w-8 h-8" />, title: 'Comunidad', desc: 'Fortalecemos lazos entre iglesias y familias, creando un ambiente de hermandad.' },
        { icon: <Shield className="w-8 h-8" />, title: 'Disciplina', desc: 'El deporte nos enseña perseverancia, respeto y trabajo en equipo.' },
        { icon: <Trophy className="w-8 h-8" />, title: 'Excelencia', desc: 'Damos lo mejor de nosotros dentro y fuera de la cancha, para la gloria de Dios.' },
    ];
    return (
        <section className="bg-[#0d0d0d] py-20 px-4">
            <div className="max-w-6xl mx-auto">
                <motion.div variants={stagger} initial="hidden" whileInView="visible" viewport={{ once: true, margin: '-50px' }}
                    className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                    {values.map((v, i) => (
                        <motion.div key={i} variants={fadeUp} className="bg-white/5 border border-white/10 rounded-2xl p-6 text-center hover:border-brand-gold/40 transition group">
                            <div className="text-brand-gold mb-4 flex justify-center group-hover:scale-110 transition-transform">{v.icon}</div>
                            <h3 className="text-white font-bold text-lg mb-2">{v.title}</h3>
                            <p className="text-gray-400 text-sm leading-relaxed">{v.desc}</p>
                        </motion.div>
                    ))}
                </motion.div>
            </div>
        </section>
    );
}

function TournamentWidget({ activeSeason, teams }: { activeSeason: Season | null; teams: Team[] }) {
    if (!activeSeason) return (
        <section id="torneo" className="bg-brand-black py-20 px-4">
            <div className="max-w-4xl mx-auto text-center">
                <Trophy className="w-16 h-16 text-brand-gold/30 mx-auto mb-4" />
                <h2 className="text-3xl font-bold text-white mb-3">Próximamente</h2>
                <p className="text-gray-400">Estamos preparando la próxima temporada. ¡Mantente atento!</p>
            </div>
        </section>
    );

    return (
        <section id="torneo" className="bg-brand-black py-20 px-4">
            <div className="max-w-6xl mx-auto">
                <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp}>
                    <div className="text-center mb-12">
                        <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Temporada Activa</span>
                        <h2 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">{activeSeason.tournament.name}</h2>
                        <p className="text-gray-400 mt-2">{activeSeason.name} · {formatDate(activeSeason.start_date)} — {formatDate(activeSeason.end_date)}</p>
                        <span className={`inline-flex items-center gap-1.5 mt-3 px-3 py-1 rounded-full text-xs font-semibold text-white ${statusColor(activeSeason.status)}`}>
                            <span className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
                            {statusLabel(activeSeason.status)}
                        </span>
                    </div>
                </motion.div>

                {teams.length > 0 && (
                    <motion.div variants={stagger} initial="hidden" whileInView="visible" viewport={{ once: true, margin: '-50px' }}
                        className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
                        {teams.map(team => (
                            <motion.div key={team.id} variants={fadeUp}
                                className="bg-white/5 border border-white/10 rounded-xl p-4 text-center hover:border-brand-gold/40 hover:bg-white/[0.08] transition group">
                                <div className="flex justify-center mb-3">
                                    <TeamLogo team={team} size={56} />
                                </div>
                                <h4 className="text-white font-semibold text-sm truncate">{team.name}</h4>
                                <p className="text-gray-500 text-xs mt-1">{team.players_count} jugadores</p>
                            </motion.div>
                        ))}
                    </motion.div>
                )}
            </div>
        </section>
    );
}

function TeamsCarousel({ teams }: { teams: Team[] }) {
    if (teams.length === 0) return null;
    const items = teams.length < 8 ? [...teams, ...teams, ...teams] : [...teams, ...teams];
    const dur = `${Math.max(22, teams.length * 3)}s`;
    return (
        <section id="equipos" className="bg-[#0a0a0a] py-16 overflow-hidden">
            <style>{`@keyframes _mqs{from{transform:translateX(0)}to{transform:translateX(-50%)}}.mq-run{animation:_mqs ${dur} linear infinite;will-change:transform}.mq-run:hover{animation-play-state:paused}`}</style>
            <div className="max-w-6xl mx-auto px-4 mb-10">
                <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="text-center">
                    <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Participantes</span>
                    <h2 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">Equipos Inscritos</h2>
                </motion.div>
            </div>
            <div className="mq-run flex gap-4" style={{ width: 'max-content', paddingInline: '1rem' }}>
                {items.map((team, i) => (
                    <div key={i} className="flex flex-col items-center bg-white/5 border border-white/10 rounded-xl p-4 flex-shrink-0 hover:border-brand-gold/40 transition-colors" style={{ width: '8.5rem' }}>
                        <TeamLogo team={team} size={50} />
                        <p className="text-white font-semibold text-xs mt-2.5 text-center leading-tight line-clamp-2">{team.name}</p>
                        <p className="text-gray-500 text-[10px] mt-1.5 flex items-center gap-1"><Users className="w-2.5 h-2.5" />{team.players_count} jug.</p>
                    </div>
                ))}
            </div>
        </section>
    );
}

function TabbedSection({ upcomingMatches, recentMatches, standings }: {
    upcomingMatches: GameMatch[];
    recentMatches: GameMatch[];
    standings: Standing[];
}) {
    const [tab, setTab] = useState<'partidos' | 'posiciones'>('partidos');

    const sortedUpcoming = [...upcomingMatches].sort(
        (a, b) => new Date(a.scheduled_at).getTime() - new Date(b.scheduled_at).getTime()
    );
    const sortedRecent = [...recentMatches].sort(
        (a, b) => new Date(b.scheduled_at).getTime() - new Date(a.scheduled_at).getTime()
    );

    const groupByDate = (matches: GameMatch[]) => {
        const groups: Record<string, GameMatch[]> = {};
        matches.forEach(m => {
            const key = new Date(m.scheduled_at).toLocaleDateString('es-CO', {
                weekday: 'long', day: 'numeric', month: 'long', timeZone: 'UTC',
            });
            if (!groups[key]) groups[key] = [];
            groups[key].push(m);
        });
        return groups;
    };

    const upcomingGrouped = groupByDate(sortedUpcoming);
    const recentGrouped = groupByDate(sortedRecent);

    const standingsGrouped: Record<string, Standing[]> = {};
    standings.forEach(s => {
        const g = s.group?.name || 'General';
        if (!standingsGrouped[g]) standingsGrouped[g] = [];
        standingsGrouped[g].push(s);
    });

    function MatchRow({ match }: { match: GameMatch }) {
        const isFinished = match.status === 'finished';
        const isLive = ['first_half', 'halftime', 'second_half', 'extra_time', 'penalties', 'warmup'].includes(match.status);
        return (
            <div className={`flex items-center py-3.5 px-4 hover:bg-white/[0.04] transition-colors ${isLive ? 'bg-green-950/30' : ''}`}>
                <div className="flex-1 flex items-center justify-end gap-2 min-w-0 pr-3">
                    <span className="text-white text-sm font-medium truncate text-right">{match.home_team.short_name || match.home_team.name}</span>
                    <TeamLogo team={match.home_team} size={26} />
                </div>
                <div className="flex-shrink-0 w-24 text-center">
                    {isFinished || isLive ? (
                        <div>
                            <div className={`flex items-center justify-center gap-1 font-extrabold text-lg ${isLive ? 'text-green-400' : 'text-white'}`}>
                                <span>{match.home_score}</span>
                                <span className="text-gray-600 font-normal mx-0.5 text-base">-</span>
                                <span>{match.away_score}</span>
                            </div>
                            {isLive ? (
                                <div className="flex items-center justify-center gap-1 mt-0.5">
                                    <span className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" />
                                    <span className="text-green-400 text-[9px] font-bold uppercase">{statusLabel(match.status)}</span>
                                </div>
                            ) : (
                                <span className="text-gray-600 text-[9px] block">Final</span>
                            )}
                        </div>
                    ) : (
                        <div>
                            <span className="text-brand-gold font-bold text-sm">
                                {new Date(match.scheduled_at).toLocaleTimeString('es-CO', { hour: '2-digit', minute: '2-digit', timeZone: 'UTC' })}
                            </span>
                            {match.match_day && <p className="text-gray-600 text-[9px] mt-0.5 truncate">{match.match_day.name}</p>}
                        </div>
                    )}
                </div>
                <div className="flex-1 flex items-center gap-2 min-w-0 pl-3">
                    <TeamLogo team={match.away_team} size={26} />
                    <span className="text-white text-sm font-medium truncate">{match.away_team.short_name || match.away_team.name}</span>
                </div>
                {match.venue && (
                    <div className="hidden lg:flex items-center gap-1 ml-4 text-gray-600 text-[10px] flex-shrink-0 max-w-[110px]">
                        <MapPin className="w-2.5 h-2.5 flex-shrink-0" />
                        <span className="truncate">{match.venue.name}</span>
                    </div>
                )}
            </div>
        );
    }

    return (
        <section id="partidos" className="bg-[#0a0a0a] py-16 px-4">
            <span id="posiciones" aria-hidden="true" className="block -mt-16 pt-16 pointer-events-none" />
            <div className="max-w-5xl mx-auto">
                <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp}>
                    <div className="flex border-b border-white/10 mb-8">
                        <button
                            onClick={() => setTab('partidos')}
                            className={`flex items-center gap-2 px-6 py-4 text-sm font-semibold border-b-2 -mb-px transition-colors ${
                                tab === 'partidos' ? 'text-brand-gold border-brand-gold' : 'text-gray-500 border-transparent hover:text-gray-200'
                            }`}
                        >
                            <Calendar className="w-4 h-4" /> Calendario
                        </button>
                        <button
                            onClick={() => setTab('posiciones')}
                            className={`flex items-center gap-2 px-6 py-4 text-sm font-semibold border-b-2 -mb-px transition-colors ${
                                tab === 'posiciones' ? 'text-brand-gold border-brand-gold' : 'text-gray-500 border-transparent hover:text-gray-200'
                            }`}
                        >
                            <Trophy className="w-4 h-4" /> Tabla de Posiciones
                        </button>
                    </div>
                </motion.div>

                {tab === 'partidos' && (
                    <motion.div key="partidos" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.25 }}>
                        {sortedUpcoming.length === 0 && sortedRecent.length === 0 ? (
                            <div className="text-center py-20 text-gray-600">
                                <Calendar className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                <p className="text-sm">No hay partidos registrados aún.</p>
                            </div>
                        ) : (
                            <>
                                {sortedUpcoming.length > 0 && (
                                    <div className="mb-10">
                                        <h3 className="flex items-center gap-2 text-gray-300 font-bold text-xs uppercase tracking-widest mb-5">
                                            <span className="w-2 h-2 rounded-full bg-brand-gold flex-shrink-0" /> Próximos Encuentros
                                        </h3>
                                        <div className="space-y-3">
                                            {Object.entries(upcomingGrouped).map(([date, matches]) => (
                                                <div key={date}>
                                                    <p className="text-gray-600 text-[10px] uppercase tracking-wider font-medium px-2 py-1.5 capitalize">{date}</p>
                                                    <div className="bg-white/[0.03] rounded-xl border border-white/5 divide-y divide-white/5 overflow-hidden">
                                                        {matches.map(m => <MatchRow key={m.id} match={m} />)}
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}
                                {sortedRecent.length > 0 && (
                                    <div>
                                        <h3 className="flex items-center gap-2 text-gray-300 font-bold text-xs uppercase tracking-widest mb-5">
                                            <span className="w-2 h-2 rounded-full bg-gray-500 flex-shrink-0" /> Resultados Recientes
                                        </h3>
                                        <div className="space-y-3">
                                            {Object.entries(recentGrouped).map(([date, matches]) => (
                                                <div key={date}>
                                                    <p className="text-gray-600 text-[10px] uppercase tracking-wider font-medium px-2 py-1.5 capitalize">{date}</p>
                                                    <div className="bg-white/[0.03] rounded-xl border border-white/5 divide-y divide-white/5 overflow-hidden">
                                                        {matches.map(m => <MatchRow key={m.id} match={m} />)}
                                                    </div>
                                                </div>
                                            ))}
                                        </div>
                                    </div>
                                )}
                            </>
                        )}
                    </motion.div>
                )}

                {tab === 'posiciones' && (
                    <motion.div key="posiciones" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.25 }}>
                        {standings.length === 0 ? (
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
                                            <table className="w-full text-sm">
                                                <thead>
                                                    <tr className="bg-white/5 text-gray-500 text-[11px] uppercase tracking-wider">
                                                        <th className="py-3 px-4 text-left w-10">#</th>
                                                        <th className="py-3 px-3 text-left">Equipo</th>
                                                        <th className="py-3 px-3 text-center">PJ</th>
                                                        <th className="py-3 px-3 text-center">G</th>
                                                        <th className="py-3 px-3 text-center">E</th>
                                                        <th className="py-3 px-3 text-center">P</th>
                                                        <th className="py-3 px-3 text-center hidden sm:table-cell">GF</th>
                                                        <th className="py-3 px-3 text-center hidden sm:table-cell">GC</th>
                                                        <th className="py-3 px-3 text-center hidden sm:table-cell">DG</th>
                                                        <th className="py-3 px-3 text-center hidden sm:table-cell" title="Total tarjetas">TJ</th>
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
                                                                    <span className="text-white font-medium text-sm">{s.team.name}</span>
                                                                </div>
                                                            </td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.played}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.won}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.drawn}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400">{s.lost}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400 hidden sm:table-cell">{s.goals_for}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400 hidden sm:table-cell">{s.goals_against}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400 hidden sm:table-cell">{s.goal_difference}</td>
                                                            <td className="py-3 px-3 text-center text-gray-400 hidden sm:table-cell">{(s.yellow_cards ?? 0) + (s.blue_cards ?? 0) + (s.red_cards ?? 0)}</td>
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
                    </motion.div>
                )}
            </div>
        </section>
    );
}

function VenuesSection({ venues }: { venues: Venue[] }) {
    if (venues.length === 0) return null;
    return (
        <section id="escenarios" className="bg-brand-black py-20 px-4">
            <div className="max-w-6xl mx-auto">
                <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="text-center mb-12">
                    <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Escenarios</span>
                    <h2 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">Nuestras Canchas</h2>
                </motion.div>

                <motion.div variants={stagger} initial="hidden" whileInView="visible" viewport={{ once: true, margin: '-50px' }}
                    className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                    {venues.map(venue => (
                        <motion.div key={venue.id} variants={fadeUp}
                            className="bg-white/5 border border-white/10 rounded-2xl overflow-hidden hover:border-brand-gold/40 transition group">
                            {venue.image ? (
                                <div className="h-44 overflow-hidden">
                                    <img src={`/storage/${venue.image}`} alt={venue.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                                </div>
                            ) : (
                                <div className="h-44 bg-white/5 flex items-center justify-center">
                                    <MapPin className="w-12 h-12 text-brand-gold/30" />
                                </div>
                            )}
                            <div className="p-5">
                                <h4 className="text-white font-bold text-base mb-1">{venue.name}</h4>
                                {venue.address && <p className="text-gray-500 text-xs flex items-center gap-1"><MapPin className="w-3 h-3" />{venue.address}{venue.city ? `, ${venue.city}` : ''}</p>}
                                <div className="flex items-center gap-3 mt-3 text-xs text-gray-400">
                                    {venue.surface_type && <span className="bg-white/10 px-2 py-0.5 rounded">{venue.surface_type}</span>}
                                    {venue.capacity && <span className="bg-white/10 px-2 py-0.5 rounded">{venue.capacity} personas</span>}
                                </div>
                            </div>
                        </motion.div>
                    ))}
                </motion.div>
            </div>
        </section>
    );
}

function Footer({ settings }: { settings: Record<string, string | null> }) {
    return (
        <footer className="bg-brand-black border-t border-white/10 py-10 px-4">
            <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                    {settings.logo
                        ? <img src={`/storage/${settings.logo}`} alt="León de Judá" className="w-8 h-8 object-contain" />
                        : <span className="text-brand-gold font-bold text-sm">LJ</span>
                    }
                    <div>
                        <p className="text-white font-semibold text-sm">{settings.site_name || 'Torneo León de Judá'}</p>
                        <p className="text-gray-600 text-xs">{settings.church_name || 'Centro de Fe y Esperanza'}</p>
                    </div>
                </div>
                <p className="text-gray-600 text-xs">© {new Date().getFullYear()} Torneo León de Judá. Todos los derechos reservados. Impulsado por <a href="https://agenciamundiweb.com/" target="_blank" rel="noopener noreferrer" className="text-brand-gold hover:underline">MundiWeb – Agencia Digital</a>.</p>
            </div>
        </footer>
    );
}

/* ───── page ───── */

export default function Home({ auth, activeSeason, teams, standings, upcomingMatches, recentMatches, venues, settings, canLogin, canRegister }: Props) {
    return (
        <>
            <Head>
                <title>{settings.site_name || 'Torneo León de Judá'}</title>
            </Head>
            <div className="bg-brand-black min-h-screen">
                <Navbar canLogin={canLogin} canRegister={canRegister} auth={auth} settings={settings} />
                <Hero settings={settings} activeSeason={activeSeason} />
                <TabbedSection upcomingMatches={upcomingMatches} recentMatches={recentMatches} standings={standings} />
                <ValuesSection />
                <TeamsCarousel teams={teams} />
                <VenuesSection venues={venues} />
                <Footer settings={settings} />
            </div>
        </>
    );
}
