import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { AnimatePresence, motion } from 'framer-motion';
import { Users, ArrowLeft, X } from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

interface Member {
    id: number;
    name: string;
    description: string | null;
    photo: string | null;
    roles: string[];
    tier: number;
    order: number;
}

type Props = PageProps<{
    members: Member[];
    roleLabels: Record<string, string>;
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };
const stagger = { visible: { transition: { staggerChildren: 0.08 } } };

const tierTitles: Record<number, string> = {
    1: 'Dirección',
    2: 'Coordinación',
    3: 'Áreas',
};

function MemberPhoto({ member, size }: { member: Member; size: 'lg' | 'md' | 'sm' }) {
    const sizeClass = size === 'lg' ? 'w-32 h-32 sm:w-36 sm:h-36' : size === 'md' ? 'w-24 h-24 sm:w-28 sm:h-28' : 'w-20 h-20';
    const fontSize = size === 'lg' ? 'text-4xl' : size === 'md' ? 'text-3xl' : 'text-2xl';

    if (member.photo) {
        return (
            <img
                src={`/storage/${member.photo}`}
                alt={member.name}
                className={`${sizeClass} rounded-2xl object-cover border-2 border-brand-gold/20 group-hover:border-brand-gold/60 transition`}
            />
        );
    }
    return (
        <div className={`${sizeClass} rounded-2xl bg-brand-gold/10 border-2 border-brand-gold/20 group-hover:border-brand-gold/60 flex items-center justify-center transition`}>
            <span className={`text-brand-gold font-extrabold ${fontSize}`}>{member.name.charAt(0).toUpperCase()}</span>
        </div>
    );
}

function RoleBadges({ roles, labels }: { roles: string[]; labels: Record<string, string> }) {
    return (
        <div className="flex flex-wrap gap-1.5 justify-center">
            {roles.map((r) => (
                <span
                    key={r}
                    className="text-[10px] font-bold uppercase tracking-wider text-brand-gold bg-brand-gold/10 border border-brand-gold/20 rounded-full px-2.5 py-1"
                >
                    {labels[r] || r}
                </span>
            ))}
        </div>
    );
}

function DirectionCard({ member, labels, onSelect }: { member: Member; labels: Record<string, string>; onSelect: () => void }) {
    return (
        <motion.div
            variants={fadeUp}
            onClick={onSelect}
            onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onSelect(); } }}
            role="button"
            tabIndex={0}
            aria-label={`Ver detalles de ${member.name}`}
            className="group bg-gradient-to-b from-white/[0.04] to-transparent border border-white/10 hover:border-brand-gold/40 rounded-2xl p-6 sm:p-8 text-center transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_-15px_rgba(214,143,3,0.25)] cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold/50"
        >
            <div className="flex flex-col items-center">
                <MemberPhoto member={member} size="lg" />
                <h3 className="mt-5 text-white font-extrabold text-xl">{member.name}</h3>
                <div className="mt-3">
                    <RoleBadges roles={member.roles} labels={labels} />
                </div>
                {member.description && (
                    <p className="mt-4 text-gray-400 text-sm leading-relaxed max-w-md">{member.description}</p>
                )}
            </div>
        </motion.div>
    );
}

function CoordinatorCard({ member, labels, onSelect }: { member: Member; labels: Record<string, string>; onSelect: () => void }) {
    return (
        <motion.div
            variants={fadeUp}
            onClick={onSelect}
            onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onSelect(); } }}
            role="button"
            tabIndex={0}
            aria-label={`Ver detalles de ${member.name}`}
            className="group bg-white/[0.03] border border-white/10 hover:border-brand-gold/30 rounded-2xl p-5 text-center transition-all hover:-translate-y-1 cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold/50"
        >
            <div className="flex flex-col items-center">
                <MemberPhoto member={member} size="md" />
                <h3 className="mt-4 text-white font-bold text-base">{member.name}</h3>
                <div className="mt-2">
                    <RoleBadges roles={member.roles} labels={labels} />
                </div>
                {member.description && (
                    <p className="mt-3 text-gray-500 text-xs leading-relaxed">{member.description}</p>
                )}
            </div>
        </motion.div>
    );
}

function AreaCard({ member, labels, onSelect }: { member: Member; labels: Record<string, string>; onSelect: () => void }) {
    return (
        <motion.div
            variants={fadeUp}
            onClick={onSelect}
            onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onSelect(); } }}
            role="button"
            tabIndex={0}
            aria-label={`Ver detalles de ${member.name}`}
            className="group bg-white/[0.02] border border-white/5 hover:border-brand-gold/25 rounded-xl p-4 text-center transition-all hover:-translate-y-0.5 cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold/50"
        >
            <div className="flex flex-col items-center">
                <MemberPhoto member={member} size="sm" />
                <h3 className="mt-3 text-white font-semibold text-sm leading-tight">{member.name}</h3>
                <div className="mt-2">
                    <RoleBadges roles={member.roles} labels={labels} />
                </div>
                {member.description && (
                    <p className="mt-2 text-gray-500 text-[11px] leading-relaxed line-clamp-3">{member.description}</p>
                )}
            </div>
        </motion.div>
    );
}

function MemberModal({
    member,
    labels,
    onClose,
}: {
    member: Member;
    labels: Record<string, string>;
    onClose: () => void;
}) {
    const [mounted, setMounted] = useState(false);

    useEffect(() => {
        setMounted(true);
    }, []);

    useEffect(() => {
        const handler = (e: KeyboardEvent) => {
            if (e.key === 'Escape') onClose();
        };
        window.addEventListener('keydown', handler);
        return () => window.removeEventListener('keydown', handler);
    }, [onClose]);

    useEffect(() => {
        const original = document.body.style.overflow;
        document.body.style.overflow = 'hidden';
        return () => {
            document.body.style.overflow = original;
        };
    }, []);

    if (!mounted) return null;

    return createPortal(
        <div className="fixed inset-0 z-[80] flex items-center justify-center p-4">
            <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.2 }}
                onClick={onClose}
                className="absolute inset-0 bg-black/80 backdrop-blur-md"
            />
            <motion.div
                initial={{ opacity: 0, scale: 0.92, y: 16 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95, y: 8 }}
                transition={{ duration: 0.25, ease: 'easeOut' }}
                role="dialog"
                aria-modal="true"
                aria-label={`Perfil de ${member.name}`}
                className="relative bg-brand-black border border-brand-gold/30 rounded-3xl max-w-md w-full max-h-[90vh] overflow-y-auto shadow-[0_0_80px_rgba(214,143,3,0.18)]"
            >
                <button
                    type="button"
                    onClick={onClose}
                    aria-label="Cerrar"
                    className="absolute top-4 right-4 z-10 inline-flex items-center justify-center w-10 h-10 rounded-full bg-black/60 backdrop-blur text-gray-200 hover:bg-black/80 hover:text-brand-gold transition"
                >
                    <X className="w-5 h-5" />
                </button>

                <div className="relative aspect-square bg-gradient-to-b from-brand-gold/5 to-brand-black">
                    {member.photo ? (
                        <img
                            src={`/storage/${member.photo}`}
                            alt={member.name}
                            className="w-full h-full object-cover"
                        />
                    ) : (
                        <div className="w-full h-full flex items-center justify-center bg-brand-gold/10">
                            <span className="text-brand-gold font-extrabold text-[8rem] leading-none">
                                {member.name.charAt(0).toUpperCase()}
                            </span>
                        </div>
                    )}
                    <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-brand-black to-transparent pointer-events-none" />
                </div>

                <div className="px-6 pb-7 pt-5 text-center">
                    <h3 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
                        {member.name}
                    </h3>
                    <div className="mt-4">
                        <RoleBadges roles={member.roles} labels={labels} />
                    </div>
                    {member.description && (
                        <p className="mt-5 text-gray-400 text-sm sm:text-base leading-relaxed whitespace-pre-line">
                            {member.description}
                        </p>
                    )}
                </div>
            </motion.div>
        </div>,
        document.body
    );
}

function TierDivider({ label }: { label: string }) {
    return (
        <div className="flex items-center justify-center my-10">
            <span className="h-px flex-1 bg-gradient-to-r from-transparent via-brand-gold/30 to-transparent max-w-xs" />
            <span className="px-5 text-brand-gold text-xs font-bold uppercase tracking-[0.3em]">{label}</span>
            <span className="h-px flex-1 bg-gradient-to-l from-transparent via-brand-gold/30 to-transparent max-w-xs" />
        </div>
    );
}

export default function Equipo({ members = [], roleLabels = {}, settings = {} }: Props) {
    const data = Array.isArray(members) ? members : [];
    const [selectedMember, setSelectedMember] = useState<Member | null>(null);

    const tier1 = data.filter((m) => m.tier === 1);
    const tier2 = data.filter((m) => m.tier === 2);
    const tier3 = data.filter((m) => m.tier === 3);

    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    return (
        <>
            <Head>
                <title>{`Equipo Organizador - ${siteName}`}</title>
                <meta name="description" content={`Organigrama y equipo organizador del ${siteName}`} />
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
                    <div className="max-w-6xl mx-auto">
                        <motion.div initial="hidden" animate="visible" variants={fadeUp} className="text-center mb-4">
                            <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-brand-gold/10 mb-4">
                                <Users className="w-7 h-7 text-brand-gold" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">Nuestro Equipo Organizador</h1>
                            <p className="text-gray-400 mt-2 text-sm max-w-xl mx-auto">
                                Conoce a las personas que hacen posible este torneo.
                            </p>
                        </motion.div>

                        {data.length === 0 ? (
                            <div className="text-center py-20 text-gray-600">
                                <Users className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                <p className="text-sm">Próximamente conocerás al equipo organizador.</p>
                            </div>
                        ) : (
                            <div className="mt-8 space-y-2">
                                {tier1.length > 0 && (
                                    <>
                                        <TierDivider label={tierTitles[1]} />
                                        <motion.div
                                            variants={stagger}
                                            initial="hidden"
                                            whileInView="visible"
                                            viewport={{ once: true, margin: '-50px' }}
                                            className={`grid gap-6 ${tier1.length === 1 ? 'grid-cols-1 max-w-md mx-auto' : 'grid-cols-1 sm:grid-cols-2 max-w-3xl mx-auto'}`}
                                        >
                                            {tier1.map((m) => (
                                                <DirectionCard key={m.id} member={m} labels={roleLabels} onSelect={() => setSelectedMember(m)} />
                                            ))}
                                        </motion.div>
                                    </>
                                )}

                                {tier2.length > 0 && (
                                    <>
                                        <TierDivider label={tierTitles[2]} />
                                        <motion.div
                                            variants={stagger}
                                            initial="hidden"
                                            whileInView="visible"
                                            viewport={{ once: true, margin: '-50px' }}
                                            className="grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-4 gap-4 max-w-4xl mx-auto"
                                        >
                                            {tier2.map((m) => (
                                                <AreaCard key={m.id} member={m} labels={roleLabels} onSelect={() => setSelectedMember(m)} />
                                            ))}
                                        </motion.div>
                                    </>
                                )}

                                {tier3.length > 0 && (
                                    <>
                                        <TierDivider label={tierTitles[3]} />
                                        <motion.div
                                            variants={stagger}
                                            initial="hidden"
                                            whileInView="visible"
                                            viewport={{ once: true, margin: '-50px' }}
                                            className="grid grid-cols-1 sm:grid-cols-3 lg:grid-cols-4 gap-4 max-w-4xl mx-auto"
                                        >
                                            {tier3.map((m) => (
                                                <AreaCard key={m.id} member={m} labels={roleLabels} onSelect={() => setSelectedMember(m)} />
                                            ))}
                                        </motion.div>
                                    </>
                                )}
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
                    {selectedMember && (
                        <MemberModal
                            key={selectedMember.id}
                            member={selectedMember}
                            labels={roleLabels}
                            onClose={() => setSelectedMember(null)}
                        />
                    )}
                </AnimatePresence>
            </div>
        </>
    );
}
