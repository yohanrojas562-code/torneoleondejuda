import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { motion } from 'framer-motion';
import {
    HandHeart, ArrowLeft, ExternalLink, Globe, MessageCircle, Music2,
} from 'lucide-react';
import MobileBottomNav from '@/Components/MobileBottomNav';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

type IconComponent = React.FC<{ className?: string }>;

const FacebookIcon: IconComponent = ({ className }) => (
    <svg viewBox="0 0 24 24" fill="currentColor" className={className} aria-hidden="true">
        <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
    </svg>
);
const InstagramIcon: IconComponent = ({ className }) => (
    <svg viewBox="0 0 24 24" fill="currentColor" className={className} aria-hidden="true">
        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24s3.668-.014 4.948-.072c4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 1 0 0 12.324 6.162 6.162 0 0 0 0-12.324zM12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8zm6.406-11.845a1.44 1.44 0 1 0 0 2.881 1.44 1.44 0 0 0 0-2.881z" />
    </svg>
);
const TwitterIcon: IconComponent = ({ className }) => (
    <svg viewBox="0 0 24 24" fill="currentColor" className={className} aria-hidden="true">
        <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231 5.45-6.231zm-1.161 17.52h1.833L7.084 4.126H5.117l11.966 15.644z" />
    </svg>
);
const YoutubeIcon: IconComponent = ({ className }) => (
    <svg viewBox="0 0 24 24" fill="currentColor" className={className} aria-hidden="true">
        <path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z" />
    </svg>
);
const LinkedinIcon: IconComponent = ({ className }) => (
    <svg viewBox="0 0 24 24" fill="currentColor" className={className} aria-hidden="true">
        <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433a2.062 2.062 0 0 1-2.063-2.065 2.063 2.063 0 1 1 2.063 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
    </svg>
);

interface Sponsor {
    id: number;
    name: string;
    description: string | null;
    logo: string | null;
    website: string | null;
    type: 'patrocinio' | 'alianza' | 'apoyo';
    social_links: Record<string, string | null>;
}

type Props = PageProps<{
    sponsors: Sponsor[];
    typeLabels: Record<string, string>;
    sectionTitles: Record<string, string>;
    settings: Record<string, string | null>;
}>;

const fadeUp = { hidden: { opacity: 0, y: 30 }, visible: { opacity: 1, y: 0 } };
const stagger = { visible: { transition: { staggerChildren: 0.07 } } };

const socialIcons: Record<string, IconComponent> = {
    facebook: FacebookIcon,
    instagram: InstagramIcon,
    twitter: TwitterIcon,
    youtube: YoutubeIcon,
    linkedin: LinkedinIcon,
    tiktok: Music2 as IconComponent,
    whatsapp: MessageCircle as IconComponent,
};

const socialLabels: Record<string, string> = {
    facebook: 'Facebook',
    instagram: 'Instagram',
    twitter: 'Twitter',
    youtube: 'YouTube',
    linkedin: 'LinkedIn',
    tiktok: 'TikTok',
    whatsapp: 'WhatsApp',
};

function SponsorLogo({ sponsor, height }: { sponsor: Sponsor; height: string }) {
    if (sponsor.logo) {
        return (
            <div className={`${height} w-full bg-white/[0.04] rounded-xl flex items-center justify-center p-4 group-hover:bg-white/[0.06] transition`}>
                <img
                    src={`/storage/${sponsor.logo}`}
                    alt={sponsor.name}
                    className="max-h-full max-w-full object-contain"
                />
            </div>
        );
    }
    return (
        <div className={`${height} w-full bg-brand-gold/10 rounded-xl flex items-center justify-center p-4`}>
            <span className="text-brand-gold font-extrabold text-3xl">{sponsor.name.charAt(0).toUpperCase()}</span>
        </div>
    );
}

function SocialLinks({ links, size = 'sm' }: { links: Record<string, string | null>; size?: 'sm' | 'xs' }) {
    const platforms = Object.entries(links).filter(([, url]) => url && url.trim() !== '');
    if (platforms.length === 0) return null;

    const iconSize = size === 'sm' ? 'w-4 h-4' : 'w-3.5 h-3.5';
    const btnSize = size === 'sm' ? 'w-8 h-8' : 'w-7 h-7';

    return (
        <div className="flex flex-wrap items-center gap-1.5 justify-center">
            {platforms.map(([platform, url]) => {
                const Icon = socialIcons[platform] || Globe;
                return (
                    <a
                        key={platform}
                        href={url as string}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label={socialLabels[platform] || platform}
                        title={socialLabels[platform] || platform}
                        className={`${btnSize} inline-flex items-center justify-center rounded-full bg-white/[0.06] hover:bg-brand-gold/15 text-gray-400 hover:text-brand-gold border border-white/10 hover:border-brand-gold/40 transition`}
                    >
                        <Icon className={iconSize} />
                    </a>
                );
            })}
        </div>
    );
}

function WebsiteLink({ url, large = false }: { url: string; large?: boolean }) {
    return (
        <a
            href={url}
            target="_blank"
            rel="noopener noreferrer"
            onClick={(e) => e.stopPropagation()}
            className={`inline-flex items-center gap-1.5 ${
                large ? 'px-4 py-2 text-sm bg-brand-gold/10 hover:bg-brand-gold/20 border border-brand-gold/30 rounded-lg text-brand-gold font-semibold' : 'text-xs text-brand-gold hover:text-brand-gold-light'
            } transition`}
        >
            <Globe className={large ? 'w-4 h-4' : 'w-3 h-3'} />
            <span>{large ? 'Visitar sitio web' : 'Sitio web'}</span>
            <ExternalLink className={large ? 'w-3.5 h-3.5' : 'w-2.5 h-2.5'} />
        </a>
    );
}

function PatrocinioCard({ sponsor, label }: { sponsor: Sponsor; label: string }) {
    return (
        <motion.div
            variants={fadeUp}
            className="group bg-gradient-to-b from-white/[0.04] to-transparent border border-white/10 hover:border-brand-gold/40 rounded-2xl p-6 sm:p-7 transition-all hover:-translate-y-1 hover:shadow-[0_20px_40px_-15px_rgba(214,143,3,0.25)]"
        >
            <div className="flex items-center justify-between mb-4">
                <span className="text-[10px] font-bold uppercase tracking-wider text-brand-gold bg-brand-gold/10 border border-brand-gold/30 rounded-full px-2.5 py-1">
                    {label}
                </span>
            </div>
            <SponsorLogo sponsor={sponsor} height="h-40" />
            <h3 className="mt-5 text-white font-extrabold text-xl text-center">{sponsor.name}</h3>
            {sponsor.description && (
                <p className="mt-3 text-gray-400 text-sm leading-relaxed text-center">{sponsor.description}</p>
            )}
            <div className="mt-5 flex flex-col items-center gap-3">
                {sponsor.website && <WebsiteLink url={sponsor.website} large />}
                <SocialLinks links={sponsor.social_links} size="sm" />
            </div>
        </motion.div>
    );
}

function AlianzaCard({ sponsor, label }: { sponsor: Sponsor; label: string }) {
    return (
        <motion.div
            variants={fadeUp}
            className="group bg-white/[0.03] border border-white/10 hover:border-brand-gold/30 rounded-2xl p-5 transition-all hover:-translate-y-1"
        >
            <div className="flex items-center justify-between mb-3">
                <span className="text-[9px] font-bold uppercase tracking-wider text-brand-gold bg-brand-gold/10 border border-brand-gold/20 rounded-full px-2 py-0.5">
                    {label}
                </span>
            </div>
            <SponsorLogo sponsor={sponsor} height="h-28" />
            <h3 className="mt-4 text-white font-bold text-base text-center">{sponsor.name}</h3>
            {sponsor.description && (
                <p className="mt-2 text-gray-500 text-xs leading-relaxed text-center line-clamp-3">{sponsor.description}</p>
            )}
            <div className="mt-4 flex flex-col items-center gap-2">
                {sponsor.website && <WebsiteLink url={sponsor.website} />}
                <SocialLinks links={sponsor.social_links} size="xs" />
            </div>
        </motion.div>
    );
}

function ApoyoCard({ sponsor }: { sponsor: Sponsor }) {
    const card = (
        <motion.div
            variants={fadeUp}
            className="group bg-white/[0.02] border border-white/5 hover:border-brand-gold/25 rounded-xl p-4 transition-all hover:-translate-y-0.5 h-full flex flex-col"
        >
            <SponsorLogo sponsor={sponsor} height="h-20" />
            <h3 className="mt-3 text-white font-semibold text-xs text-center leading-tight">{sponsor.name}</h3>
            {Object.values(sponsor.social_links).some((u) => u) && (
                <div className="mt-2.5">
                    <SocialLinks links={sponsor.social_links} size="xs" />
                </div>
            )}
        </motion.div>
    );

    if (sponsor.website) {
        return (
            <a
                href={sponsor.website}
                target="_blank"
                rel="noopener noreferrer"
                className="block focus:outline-none focus-visible:ring-2 focus-visible:ring-brand-gold/40 rounded-xl"
            >
                {card}
            </a>
        );
    }
    return card;
}

function TierDivider({ label }: { label: string }) {
    return (
        <div className="flex items-center justify-center my-10">
            <span className="h-px flex-1 bg-gradient-to-r from-transparent via-brand-gold/30 to-transparent max-w-xs" />
            <span className="px-5 text-brand-gold text-xs font-bold uppercase tracking-[0.3em] text-center">{label}</span>
            <span className="h-px flex-1 bg-gradient-to-l from-transparent via-brand-gold/30 to-transparent max-w-xs" />
        </div>
    );
}

export default function Patrocinadores({ sponsors = [], typeLabels = {}, sectionTitles = {}, settings = {} }: Props) {
    const data = Array.isArray(sponsors) ? sponsors : [];

    const patrocinios = data.filter((s) => s.type === 'patrocinio');
    const alianzas = data.filter((s) => s.type === 'alianza');
    const apoyos = data.filter((s) => s.type === 'apoyo');

    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;

    return (
        <>
            <Head>
                <title>{`Patrocinadores - ${siteName}`}</title>
                <meta name="description" content={`Patrocinadores, aliados y apoyos del ${siteName}`} />
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
                                <HandHeart className="w-7 h-7 text-brand-gold" />
                            </div>
                            <h1 className="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">Patrocinadores</h1>
                            <p className="text-gray-400 mt-2 text-sm max-w-xl mx-auto">
                                Gracias a quienes hacen posible este torneo con su apoyo y compromiso.
                            </p>
                        </motion.div>

                        {data.length === 0 ? (
                            <div className="text-center py-20 text-gray-600">
                                <HandHeart className="w-14 h-14 mx-auto mb-4 opacity-20" />
                                <p className="text-sm">Próximamente conocerás a nuestros patrocinadores y aliados.</p>
                            </div>
                        ) : (
                            <div className="mt-8 space-y-2">
                                {patrocinios.length > 0 && (
                                    <>
                                        <TierDivider label={sectionTitles['patrocinio'] || 'Patrocinadores Oficiales'} />
                                        <motion.div
                                            variants={stagger}
                                            initial="hidden"
                                            whileInView="visible"
                                            viewport={{ once: true, margin: '-50px' }}
                                            className={`grid gap-6 mx-auto ${
                                                patrocinios.length === 1
                                                    ? 'grid-cols-1 max-w-sm'
                                                    : patrocinios.length === 2
                                                        ? 'grid-cols-1 sm:grid-cols-2 max-w-3xl'
                                                        : 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 max-w-5xl'
                                            }`}
                                        >
                                            {patrocinios.map((s) => (
                                                <PatrocinioCard key={s.id} sponsor={s} label={typeLabels['patrocinio'] || 'Patrocinador'} />
                                            ))}
                                        </motion.div>
                                    </>
                                )}

                                {alianzas.length > 0 && (
                                    <>
                                        <TierDivider label={sectionTitles['alianza'] || 'Alianzas'} />
                                        <motion.div
                                            variants={stagger}
                                            initial="hidden"
                                            whileInView="visible"
                                            viewport={{ once: true, margin: '-50px' }}
                                            className={`grid gap-5 mx-auto ${
                                                alianzas.length === 1
                                                    ? 'grid-cols-1 max-w-xs'
                                                    : alianzas.length === 2
                                                        ? 'grid-cols-1 sm:grid-cols-2 max-w-2xl'
                                                        : 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 max-w-5xl'
                                            }`}
                                        >
                                            {alianzas.map((s) => (
                                                <AlianzaCard key={s.id} sponsor={s} label={typeLabels['alianza'] || 'Aliado'} />
                                            ))}
                                        </motion.div>
                                    </>
                                )}

                                {apoyos.length > 0 && (
                                    <>
                                        <TierDivider label={sectionTitles['apoyo'] || 'Apoyo'} />
                                        <motion.div
                                            variants={stagger}
                                            initial="hidden"
                                            whileInView="visible"
                                            viewport={{ once: true, margin: '-50px' }}
                                            className={`grid gap-3 mx-auto ${
                                                apoyos.length === 1
                                                    ? 'grid-cols-1 max-w-[180px]'
                                                    : apoyos.length === 2
                                                        ? 'grid-cols-2 max-w-sm'
                                                        : 'grid-cols-2 sm:grid-cols-3 lg:grid-cols-5'
                                            }`}
                                        >
                                            {apoyos.map((s) => (
                                                <ApoyoCard key={s.id} sponsor={s} />
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
            </div>
        </>
    );
}
