import { useState } from 'react';
import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import { CheckCircle2, Copy, ArrowLeft, Mail, Home as HomeIcon } from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

type Props = PageProps<{
    caseNumber: string;
    type: string;
    typeLabel: string;
    subject: string;
    submitterEmail: string;
    createdAt: string;
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };

export default function PqrsSuccess({ caseNumber, typeLabel, subject, submitterEmail, createdAt, settings = {} }: Props) {
    const [copied, setCopied] = useState(false);
    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    const copyCase = async () => {
        try {
            await navigator.clipboard.writeText(caseNumber);
            setCopied(true);
            setTimeout(() => setCopied(false), 2000);
        } catch {
            /* clipboard not available */
        }
    };

    const formatted = new Date(createdAt).toLocaleString('es-CO', {
        day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit',
    });

    return (
        <>
            <Head>
                <title>{`Solicitud enviada - ${siteName}`}</title>
            </Head>

            <div className="bg-brand-black min-h-screen flex flex-col">
                <header className="bg-brand-black/95 backdrop-blur-sm border-b border-brand-gold/20">
                    <div className="max-w-3xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
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
                    <div className="max-w-xl w-full">
                        <motion.div initial="hidden" animate="visible" variants={fadeUp} className="text-center">
                            <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-green-500/15 mb-6">
                                <CheckCircle2 className="w-10 h-10 text-green-400" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight mb-2">
                                ¡Solicitud enviada!
                            </h1>
                            <p className="text-gray-400 text-sm mb-8">
                                Hemos recibido tu {typeLabel.toLowerCase()} y la atenderemos lo antes posible.
                            </p>

                            <div className="bg-white/[0.03] border border-brand-gold/20 rounded-2xl p-6 text-left">
                                <p className="text-gray-500 text-xs uppercase tracking-wider font-semibold mb-2">Tu número de caso</p>
                                <div className="flex items-center justify-between gap-3 bg-brand-black/50 border border-brand-gold/40 rounded-xl px-4 py-3 mb-5">
                                    <span className="text-brand-gold font-extrabold text-xl tracking-wide font-mono">{caseNumber}</span>
                                    <button
                                        type="button"
                                        onClick={copyCase}
                                        className="flex items-center gap-1.5 text-gray-400 hover:text-brand-gold transition text-xs font-semibold"
                                        title="Copiar al portapapeles"
                                    >
                                        {copied ? (
                                            <><CheckCircle2 className="w-4 h-4 text-green-400" />Copiado</>
                                        ) : (
                                            <><Copy className="w-4 h-4" />Copiar</>
                                        )}
                                    </button>
                                </div>

                                <dl className="space-y-3 text-sm">
                                    <div className="flex justify-between gap-4">
                                        <dt className="text-gray-500">Tipo</dt>
                                        <dd className="text-white font-semibold">{typeLabel}</dd>
                                    </div>
                                    <div className="flex justify-between gap-4">
                                        <dt className="text-gray-500">Asunto</dt>
                                        <dd className="text-white text-right truncate max-w-[60%]">{subject}</dd>
                                    </div>
                                    <div className="flex justify-between gap-4">
                                        <dt className="text-gray-500">Enviado</dt>
                                        <dd className="text-white text-right">{formatted}</dd>
                                    </div>
                                </dl>

                                <div className="mt-5 pt-5 border-t border-white/10 flex items-start gap-2.5 text-xs text-gray-400">
                                    <Mail className="w-4 h-4 text-brand-gold flex-shrink-0 mt-0.5" />
                                    <p>
                                        Guarda tu número de caso. Te contactaremos en
                                        <span className="text-white font-semibold"> {submitterEmail} </span>
                                        cuando tengamos novedades.
                                    </p>
                                </div>
                            </div>

                            <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center">
                                <Link
                                    href="/"
                                    className="inline-flex items-center justify-center gap-2 bg-brand-gold hover:bg-brand-gold-light text-black font-bold px-5 py-2.5 rounded-lg transition text-sm"
                                >
                                    <HomeIcon className="w-4 h-4" />
                                    Volver al inicio
                                </Link>
                                <Link
                                    href="/pqrs"
                                    className="inline-flex items-center justify-center gap-2 bg-white/[0.05] hover:bg-white/[0.08] border border-white/10 text-white font-semibold px-5 py-2.5 rounded-lg transition text-sm"
                                >
                                    Enviar otra solicitud
                                </Link>
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
