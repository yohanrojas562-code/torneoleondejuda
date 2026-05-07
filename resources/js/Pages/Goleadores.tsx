import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import { Target, ArrowLeft, Sparkles } from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

interface Tournament { id: number; name: string; logo: string | null; }
interface Season { id: number; name: string; status: string; tournament: Tournament; }

type Props = PageProps<{
    activeSeason: Season | null;
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };

export default function Goleadores({ activeSeason, settings = {} }: Props) {
    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    return (
        <>
            <Head>
                <title>{`Tabla de Goleadores - ${siteName}`}</title>
                <meta name="description" content={`Tabla de goleadores del ${siteName}`} />
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

                <main className="flex-1 py-12 px-4 flex items-center justify-center">
                    <div className="max-w-xl mx-auto w-full">
                        <motion.div initial="hidden" animate="visible" variants={fadeUp} className="text-center">
                            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-brand-gold/10 mb-5">
                                <Target className="w-8 h-8 text-brand-gold" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight mb-2">Tabla de Goleadores</h1>
                            {activeSeason && (
                                <p className="text-gray-400 text-sm mb-10">
                                    {activeSeason.tournament?.name} · {activeSeason.name}
                                </p>
                            )}

                            <div className="bg-white/[0.03] border border-white/10 rounded-2xl px-6 py-12 mt-6">
                                <Sparkles className="w-10 h-10 text-brand-gold/60 mx-auto mb-4" />
                                <h2 className="text-xl font-bold text-white mb-2">Próximamente</h2>
                                <p className="text-gray-500 text-sm leading-relaxed max-w-sm mx-auto">
                                    Estamos preparando la tabla de goleadores del torneo. Muy pronto podrás consultar a los máximos artilleros.
                                </p>
                            </div>
                        </motion.div>
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
