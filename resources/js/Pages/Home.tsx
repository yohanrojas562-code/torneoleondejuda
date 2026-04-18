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
interface Standing { id: number; team: { id: number; name: string; short_name: string | null; logo: string | null }; group: { id: number; name: string } | null; played: number; won: number; drawn: number; lost: number; goals_for: number; goals_against: number; goal_difference: number; points: number; position: number; }
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
    return new Date(d).toLocaleDateString('es-CO', { day: 'numeric', month: 'short', year: 'numeric' });
}
function formatDateTime(d: string) {
    return new Date(d).toLocaleDateString('es-CO', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
}

function statusLabel(s: string) {
    const map: Record<string, string> = { in_progress: 'En curso', upcoming: 'Próximamente', completed: 'Finalizada', scheduled: 'Programado' };
    return map[s] || s;
}
function statusColor(s: string) {
    const map: Record<string, string> = { in_progress: 'bg-green-500', upcoming: 'bg-yellow-500', completed: 'bg-gray-500', scheduled: 'bg-blue-500' };
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

function Navbar({ canLogin, canRegister, auth }: { canLogin: boolean; canRegister: boolean; auth: { user: any } }) {
    return (
        <nav className="fixed top-0 left-0 right-0 z-50 bg-brand-black/95 backdrop-blur-sm border-b border-brand-gold/20">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex items-center justify-between h-16">
                <Link href="/" className="flex items-center gap-3">
                    <img src="/storage/site/01KPGXECZX5VF8YQAA8AD210WM.png" alt="León de Judá" className="h-10 w-10 object-contain" />
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
                        <Link href="/admin" className="bg-brand-gold hover:bg-brand-gold-light text-black font-semibold px-4 py-2 rounded-lg text-sm transition">
                            Panel <ArrowRight className="inline w-4 h-4 ml-1" />
                        </Link>
                    ) : (
                        <>
                            {canLogin && (
                                <Link href="/admin/login" className="text-gray-300 hover:text-white px-3 py-2 text-sm flex items-center gap-1 transition">
                                    <LogIn className="w-4 h-4" /> Ingresar
                                </Link>
                            )}
                            {canRegister && (
                                <Link href="/admin/register" className="bg-brand-gold hover:bg-brand-gold-light text-black font-semibold px-4 py-2 rounded-lg text-sm transition">
                                    <UserPlus className="inline w-4 h-4 mr-1" /> Inscribirse
                                </Link>
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

            <div className="relative z-10 text-center px-4 max-w-4xl mx-auto">
                <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ duration: 0.6 }}>
                    <img src="/storage/site/01KPGXECZX5VF8YQAA8AD210WM.png" alt="León de Judá" className="w-32 h-32 sm:w-40 sm:h-40 mx-auto mb-6 object-contain drop-shadow-[0_0_30px_rgba(214,143,3,0.3)]" />
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
                    {settings.site_description || 'Un espacio donde la fe, la disciplina y el deporte se encuentran. Más que un torneo, es una familia unida en Cristo.'}
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

                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.8, duration: 0.6 }} className="flex flex-col sm:flex-row items-center justify-center gap-3">
                    <a href="#torneo" className="bg-brand-gold hover:bg-brand-gold-light text-black font-bold px-8 py-3 rounded-xl text-sm transition transform hover:scale-105 flex items-center gap-2">
                        <Swords className="w-5 h-5" /> Ver Torneo
                    </a>
                    <Link href="/admin/register" className="border border-brand-gold/40 text-brand-gold hover:bg-brand-gold/10 font-semibold px-8 py-3 rounded-xl text-sm transition flex items-center gap-2">
                        <UserPlus className="w-5 h-5" /> Inscribir Equipo
                    </Link>
                </motion.div>
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

function TeamsSection({ teams }: { teams: Team[] }) {
    if (teams.length === 0) return null;
    return (
        <section id="equipos" className="bg-[#0d0d0d] py-20 px-4">
            <div className="max-w-6xl mx-auto">
                <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="text-center mb-12">
                    <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Participantes</span>
                    <h2 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">Equipos Inscritos</h2>
                </motion.div>

                <motion.div variants={stagger} initial="hidden" whileInView="visible" viewport={{ once: true, margin: '-50px' }}
                    className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                    {teams.map(team => (
                        <motion.div key={team.id} variants={fadeUp}
                            className="bg-white/5 border border-white/10 rounded-2xl p-6 flex items-center gap-4 hover:border-brand-gold/40 transition group">
                            <TeamLogo team={team} size={64} />
                            <div className="flex-1 min-w-0">
                                <h4 className="text-white font-bold text-base truncate">{team.name}</h4>
                                {team.short_name && <p className="text-gray-500 text-xs">{team.short_name}</p>}
                                <div className="flex items-center gap-1 mt-2">
                                    <Users className="w-3.5 h-3.5 text-brand-gold" />
                                    <span className="text-gray-400 text-xs">{team.players_count} jugadores aprobados</span>
                                </div>
                            </div>
                            <div className="w-3 h-8 rounded-full opacity-60" style={{ backgroundColor: team.primary_color || '#D68F03' }} />
                        </motion.div>
                    ))}
                </motion.div>
            </div>
        </section>
    );
}

function MatchesSection({ upcomingMatches, recentMatches }: { upcomingMatches: GameMatch[]; recentMatches: GameMatch[] }) {
    if (upcomingMatches.length === 0 && recentMatches.length === 0) return null;

    function MatchCard({ match }: { match: GameMatch }) {
        const isCompleted = match.status === 'completed';
        const isLive = match.status === 'in_progress';
        return (
            <div className={`bg-white/5 border rounded-xl p-4 transition ${isLive ? 'border-green-500/50 shadow-[0_0_20px_rgba(34,197,94,0.1)]' : 'border-white/10 hover:border-brand-gold/30'}`}>
                {match.match_day && <p className="text-gray-500 text-xs mb-3 text-center">{match.match_day.name}</p>}
                <div className="flex items-center justify-between gap-2">
                    <div className="flex-1 flex flex-col items-center text-center min-w-0">
                        <TeamLogo team={match.home_team} size={36} />
                        <span className="text-white text-xs font-medium mt-1.5 truncate w-full">{match.home_team.short_name || match.home_team.name}</span>
                    </div>
                    <div className="flex-shrink-0 text-center px-2">
                        {isCompleted || isLive ? (
                            <div className="flex items-center gap-1">
                                <span className="text-white text-2xl font-extrabold">{match.home_score}</span>
                                <span className="text-gray-600 text-lg">-</span>
                                <span className="text-white text-2xl font-extrabold">{match.away_score}</span>
                            </div>
                        ) : (
                            <div className="text-brand-gold text-xs font-semibold">
                                {formatDateTime(match.scheduled_at)}
                            </div>
                        )}
                        {isLive && (
                            <span className="text-green-400 text-[10px] font-bold uppercase flex items-center justify-center gap-1 mt-1">
                                <span className="w-1.5 h-1.5 rounded-full bg-green-400 animate-pulse" /> EN VIVO
                            </span>
                        )}
                    </div>
                    <div className="flex-1 flex flex-col items-center text-center min-w-0">
                        <TeamLogo team={match.away_team} size={36} />
                        <span className="text-white text-xs font-medium mt-1.5 truncate w-full">{match.away_team.short_name || match.away_team.name}</span>
                    </div>
                </div>
                {match.venue && <p className="text-gray-600 text-[10px] text-center mt-3 flex items-center justify-center gap-1"><MapPin className="w-3 h-3" />{match.venue.name}</p>}
            </div>
        );
    }

    return (
        <section id="partidos" className="bg-brand-black py-20 px-4">
            <div className="max-w-6xl mx-auto">
                <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="text-center mb-12">
                    <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Calendario</span>
                    <h2 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">Partidos</h2>
                </motion.div>

                {upcomingMatches.length > 0 && (
                    <div className="mb-10">
                        <h3 className="text-white font-semibold text-lg mb-4 flex items-center gap-2">
                            <Calendar className="w-5 h-5 text-brand-gold" /> Próximos Partidos
                        </h3>
                        <motion.div variants={stagger} initial="hidden" whileInView="visible" viewport={{ once: true }}
                            className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                            {upcomingMatches.map(m => <motion.div key={m.id} variants={fadeUp}><MatchCard match={m} /></motion.div>)}
                        </motion.div>
                    </div>
                )}

                {recentMatches.length > 0 && (
                    <div>
                        <h3 className="text-white font-semibold text-lg mb-4 flex items-center gap-2">
                            <Clock className="w-5 h-5 text-gray-400" /> Resultados Recientes
                        </h3>
                        <motion.div variants={stagger} initial="hidden" whileInView="visible" viewport={{ once: true }}
                            className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                            {recentMatches.map(m => <motion.div key={m.id} variants={fadeUp}><MatchCard match={m} /></motion.div>)}
                        </motion.div>
                    </div>
                )}
            </div>
        </section>
    );
}

function StandingsSection({ standings }: { standings: Standing[] }) {
    if (standings.length === 0) return null;

    // Group standings by group
    const grouped: Record<string, Standing[]> = {};
    standings.forEach(s => {
        const gName = s.group?.name || 'General';
        if (!grouped[gName]) grouped[gName] = [];
        grouped[gName].push(s);
    });

    return (
        <section id="posiciones" className="bg-[#0d0d0d] py-20 px-4">
            <div className="max-w-6xl mx-auto">
                <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="text-center mb-12">
                    <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Clasificación</span>
                    <h2 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">Tabla de Posiciones</h2>
                </motion.div>

                <div className="space-y-8">
                    {Object.entries(grouped).map(([groupName, rows]) => (
                        <motion.div key={groupName} initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp}>
                            {Object.keys(grouped).length > 1 && (
                                <h3 className="text-brand-gold font-semibold text-sm uppercase tracking-wider mb-3">{groupName}</h3>
                            )}
                            <div className="overflow-x-auto rounded-xl border border-white/10">
                                <table className="w-full text-sm">
                                    <thead>
                                        <tr className="bg-white/5 text-gray-400 text-xs uppercase tracking-wider">
                                            <th className="py-3 px-4 text-left">#</th>
                                            <th className="py-3 px-4 text-left">Equipo</th>
                                            <th className="py-3 px-2 text-center">PJ</th>
                                            <th className="py-3 px-2 text-center">G</th>
                                            <th className="py-3 px-2 text-center">E</th>
                                            <th className="py-3 px-2 text-center">P</th>
                                            <th className="py-3 px-2 text-center hidden sm:table-cell">GF</th>
                                            <th className="py-3 px-2 text-center hidden sm:table-cell">GC</th>
                                            <th className="py-3 px-2 text-center hidden sm:table-cell">DG</th>
                                            <th className="py-3 px-2 text-center font-bold">PTS</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {rows.map((s, i) => (
                                            <tr key={s.id} className={`border-t border-white/5 hover:bg-white/5 transition ${i < 2 ? 'border-l-2 border-l-brand-gold' : ''}`}>
                                                <td className="py-3 px-4 text-gray-400 font-medium">{s.position || i + 1}</td>
                                                <td className="py-3 px-4">
                                                    <div className="flex items-center gap-2">
                                                        <TeamLogo team={s.team} size={24} />
                                                        <span className="text-white font-medium text-sm">{s.team.short_name || s.team.name}</span>
                                                    </div>
                                                </td>
                                                <td className="py-3 px-2 text-center text-gray-300">{s.played}</td>
                                                <td className="py-3 px-2 text-center text-gray-300">{s.won}</td>
                                                <td className="py-3 px-2 text-center text-gray-300">{s.drawn}</td>
                                                <td className="py-3 px-2 text-center text-gray-300">{s.lost}</td>
                                                <td className="py-3 px-2 text-center text-gray-300 hidden sm:table-cell">{s.goals_for}</td>
                                                <td className="py-3 px-2 text-center text-gray-300 hidden sm:table-cell">{s.goals_against}</td>
                                                <td className="py-3 px-2 text-center text-gray-300 hidden sm:table-cell">{s.goal_difference}</td>
                                                <td className="py-3 px-2 text-center text-white font-extrabold text-base">{s.points}</td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </motion.div>
                    ))}
                </div>
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
                    <img src="/storage/site/01KPGXECZX5VF8YQAA8AD210WM.png" alt="León de Judá" className="w-8 h-8 object-contain" />
                    <div>
                        <p className="text-white font-semibold text-sm">{settings.site_name || 'Torneo León de Judá'}</p>
                        <p className="text-gray-600 text-xs">{settings.church_name || 'Centro de Fe y Esperanza'}</p>
                    </div>
                </div>
                <p className="text-gray-600 text-xs">© {new Date().getFullYear()} Torneo León de Judá. Todos los derechos reservados.</p>
            </div>
        </footer>
    );
}

/* ───── page ───── */

export default function Home({ auth, activeSeason, teams, standings, upcomingMatches, recentMatches, venues, settings, canLogin, canRegister }: Props) {
    return (
        <>
            <Head title={settings.site_name || 'Torneo León de Judá'} />
            <div className="bg-brand-black min-h-screen">
                <Navbar canLogin={canLogin} canRegister={canRegister} auth={auth} />
                <Hero settings={settings} activeSeason={activeSeason} />
                <ValuesSection />
                <TournamentWidget activeSeason={activeSeason} teams={teams} />
                <TeamsSection teams={teams} />
                <MatchesSection upcomingMatches={upcomingMatches} recentMatches={recentMatches} />
                <StandingsSection standings={standings} />
                <VenuesSection venues={venues} />
                <Footer settings={settings} />
            </div>
        </>
    );
}
