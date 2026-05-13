import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import {
    Info, ArrowLeft, Trophy, Users, Shield, Calendar, Star, Swords,
} from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

interface Tournament { id: number; name: string; logo: string | null; }
interface Season { id: number; name: string; status: string; tournament: Tournament; }

type Props = PageProps<{
    activeSeason: Season | null;
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };
const stagger = { visible: { transition: { staggerChildren: 0.08 } } };

export default function Acerca({ activeSeason, settings = {} }: Props) {
    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    const values = [
        { icon: <Star className="w-8 h-8" />, title: 'Fe en Cristo', desc: 'Cada jugada es un testimonio de nuestra fe y compromiso con los valores del Evangelio.' },
        { icon: <Users className="w-8 h-8" />, title: 'Comunidad', desc: 'Fortalecemos lazos entre iglesias y familias, creando un ambiente de hermandad.' },
        { icon: <Shield className="w-8 h-8" />, title: 'Disciplina', desc: 'El deporte nos enseña perseverancia, respeto y trabajo en equipo.' },
        { icon: <Trophy className="w-8 h-8" />, title: 'Excelencia', desc: 'Damos lo mejor de nosotros dentro y fuera de la cancha, para la gloria de Dios.' },
    ];

    const highlights = activeSeason ? [
        { icon: <Trophy className="w-6 h-6" />, label: 'Torneo', value: activeSeason.tournament.name },
        { icon: <Users className="w-6 h-6" />, label: 'Iglesia', value: settings.church_name || 'Centro de Fe y Esperanza' },
        { icon: <Calendar className="w-6 h-6" />, label: 'Temporada', value: activeSeason.name },
        { icon: <Swords className="w-6 h-6" />, label: 'Disciplina', value: 'Fútbol de Salón' },
    ] : [];

    return (
        <>
            <Head>
                <title>{`Sobre el Torneo - ${siteName}`}</title>
                <meta name="description" content={`Conoce más sobre el ${siteName} — valores, historia y propósito.`} />
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

                <main className="flex-1">
                    <section className="py-12 px-4">
                        <div className="max-w-3xl mx-auto text-center">
                            <motion.div initial="hidden" animate="visible" variants={fadeUp}>
                                <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-brand-gold/10 mb-4">
                                    <Info className="w-7 h-7 text-brand-gold" />
                                </div>
                                <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Conoce</span>
                                <h1 className="text-3xl sm:text-4xl font-extrabold text-white mt-2 tracking-tight">Sobre el Torneo</h1>
                                {activeSeason && (
                                    <p className="text-gray-400 mt-3 text-sm">
                                        {activeSeason.tournament.name} · {activeSeason.name}
                                    </p>
                                )}
                            </motion.div>
                        </div>
                    </section>

                    {activeSeason && (
                        <section className="bg-white/[0.02] py-16 px-4 border-y border-white/10">
                            <div className="max-w-6xl mx-auto">
                                <div className="grid md:grid-cols-2 gap-12 items-center">
                                    <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp}>
                                        <p className="text-gray-300 text-lg leading-relaxed mb-6">
                                            {settings.site_description || 'Un torneo diseñado para unir la comunidad a través del deporte y los valores cristianos.'}
                                        </p>
                                        <motion.div variants={stagger} initial="hidden" whileInView="visible" viewport={{ once: true }} className="space-y-4">
                                            {highlights.map((h, i) => (
                                                <motion.div key={i} variants={fadeUp} className="flex items-center gap-4 bg-white/5 border border-white/10 rounded-lg p-4 hover:border-brand-gold/40 transition">
                                                    <div className="text-brand-gold flex-shrink-0">{h.icon}</div>
                                                    <div>
                                                        <p className="text-gray-500 text-xs uppercase tracking-wider">{h.label}</p>
                                                        <p className="text-white font-semibold">{h.value}</p>
                                                    </div>
                                                </motion.div>
                                            ))}
                                        </motion.div>
                                    </motion.div>

                                    <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="grid grid-cols-2 gap-4">
                                        <div className="bg-gradient-to-br from-brand-gold/10 to-brand-gold/5 border border-brand-gold/30 rounded-2xl p-6 text-center hover:border-brand-gold/60 transition">
                                            <p className="text-brand-gold text-2xl font-bold">∞</p>
                                            <p className="text-white font-semibold text-sm mt-2">Fe Inquebrantable</p>
                                        </div>
                                        <div className="bg-gradient-to-br from-white/5 to-white/[0.02] border border-white/10 rounded-2xl p-6 text-center hover:border-brand-gold/40 transition">
                                            <p className="text-white text-2xl font-bold">+</p>
                                            <p className="text-gray-400 font-semibold text-sm mt-2">Comunidad Unida</p>
                                        </div>
                                        <div className="bg-gradient-to-br from-white/5 to-white/[0.02] border border-white/10 rounded-2xl p-6 text-center hover:border-brand-gold/40 transition">
                                            <p className="text-white text-2xl font-bold">=</p>
                                            <p className="text-gray-400 font-semibold text-sm mt-2">Valores en Acción</p>
                                        </div>
                                        <div className="bg-gradient-to-br from-brand-gold/10 to-brand-gold/5 border border-brand-gold/30 rounded-2xl p-6 text-center hover:border-brand-gold/60 transition">
                                            <p className="text-brand-gold text-2xl font-bold">✓</p>
                                            <p className="text-white font-semibold text-sm mt-2">Excelencia Total</p>
                                        </div>
                                    </motion.div>
                                </div>
                            </div>
                        </section>
                    )}

                    <section className="bg-[#0d0d0d] py-16 px-4">
                        <div className="max-w-6xl mx-auto">
                            <motion.div initial="hidden" whileInView="visible" viewport={{ once: true }} variants={fadeUp} className="text-center mb-10">
                                <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Lo que nos mueve</span>
                                <h2 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">Nuestros Valores</h2>
                            </motion.div>

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
