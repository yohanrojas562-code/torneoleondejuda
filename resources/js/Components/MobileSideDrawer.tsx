import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { Link, usePage } from '@inertiajs/react';
import {
    Menu, X, Home, Calendar, Trophy, Target, MessageSquare, ArrowRight, LogIn, Users, HandHeart, Shield, Info, ShieldCheck,
} from 'lucide-react';

const items = [
    { href: '/', label: 'Inicio', icon: Home },
    { href: '/calendario', label: 'Calendario', icon: Calendar },
    { href: '/tabla-de-posiciones', label: 'Tabla de Posiciones', icon: Trophy },
    { href: '/goleadores', label: 'Tabla de Goleadores', icon: Target },
    { href: '/valla-menos-vencida', label: 'Valla Menos Vencida', icon: Shield },
    { href: '/verificar', label: 'Validar Jugador', icon: ShieldCheck },
    { href: '/equipo', label: 'Equipo', icon: Users },
    { href: '/patrocinadores', label: 'Patrocinadores', icon: HandHeart },
    { href: '/acerca-del-torneo', label: 'Sobre el Torneo', icon: Info },
    { href: '/pqrs', label: 'PQRS', icon: MessageSquare },
];

export default function MobileSideDrawer({ className = '' }: { className?: string }) {
    const [open, setOpen] = useState(false);
    const [mounted, setMounted] = useState(false);
    const { url, props } = usePage();
    const auth = (props as { auth?: { user?: { id: number; name: string } | null } })?.auth;

    const currentPath = url.split('?')[0];

    const isActive = (href: string) => {
        if (href === '/') return currentPath === '/';
        return currentPath === href || currentPath.startsWith(href + '/');
    };

    useEffect(() => {
        setMounted(true);
    }, []);

    useEffect(() => {
        const handler = (e: KeyboardEvent) => {
            if (e.key === 'Escape') setOpen(false);
        };
        if (open) window.addEventListener('keydown', handler);
        return () => window.removeEventListener('keydown', handler);
    }, [open]);

    useEffect(() => {
        if (open) {
            const original = document.body.style.overflow;
            document.body.style.overflow = 'hidden';
            return () => { document.body.style.overflow = original; };
        }
    }, [open]);

    const drawer = (
        <>
            <div
                onClick={() => setOpen(false)}
                aria-hidden="true"
                className={`md:hidden fixed inset-0 bg-black/70 backdrop-blur-sm z-[60] transition-opacity duration-300 ${
                    open ? 'opacity-100' : 'opacity-0 pointer-events-none'
                }`}
            />

            <aside
                role="dialog"
                aria-modal="true"
                aria-label="Menú principal"
                className={`md:hidden fixed top-0 right-0 bottom-0 w-[85%] max-w-sm bg-brand-black border-l border-brand-gold/20 z-[70] flex flex-col shadow-[0_0_50px_rgba(0,0,0,0.6)] transform transition-transform duration-300 ease-out ${
                    open ? 'translate-x-0' : 'translate-x-full'
                }`}
            >
                <div className="flex items-center justify-between px-5 py-4 border-b border-white/10 bg-gradient-to-r from-brand-gold/[0.04] to-transparent">
                    <span className="text-brand-gold font-bold text-xs uppercase tracking-[0.2em]">Menú</span>
                    <button
                        type="button"
                        onClick={() => setOpen(false)}
                        className="inline-flex items-center justify-center w-9 h-9 rounded-lg text-gray-400 hover:bg-white/5 hover:text-brand-gold transition"
                        aria-label="Cerrar menú"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                <nav className="flex-1 overflow-y-auto py-3">
                    <ul className="space-y-1 px-3">
                        {items.map(({ href, label, icon: Icon }) => {
                            const active = isActive(href);
                            return (
                                <li key={href}>
                                    <Link
                                        href={href}
                                        onClick={() => setOpen(false)}
                                        className={`flex items-center gap-3 px-3 py-3 rounded-xl transition group ${
                                            active
                                                ? 'bg-brand-gold/10 text-brand-gold'
                                                : 'text-gray-300 hover:bg-white/[0.04] hover:text-white'
                                        }`}
                                    >
                                        <span className={`inline-flex items-center justify-center w-10 h-10 rounded-lg transition ${
                                            active ? 'bg-brand-gold/15' : 'bg-white/[0.04] group-hover:bg-white/10'
                                        }`}>
                                            <Icon className={`w-5 h-5 ${active ? 'text-brand-gold' : 'text-gray-400 group-hover:text-gray-200'}`} strokeWidth={active ? 2.5 : 2} />
                                        </span>
                                        <span className={`text-sm flex-1 ${active ? 'font-bold' : 'font-medium'}`}>{label}</span>
                                        {active && <span className="w-1.5 h-1.5 rounded-full bg-brand-gold" />}
                                    </Link>
                                </li>
                            );
                        })}
                    </ul>
                </nav>

                <div className="border-t border-white/10 p-4">
                    {auth?.user ? (
                        <a
                            href="/admin"
                            className="flex items-center justify-between gap-3 bg-brand-gold hover:bg-brand-gold-light text-black font-bold px-4 py-3 rounded-xl transition text-sm"
                        >
                            <span>Panel admin</span>
                            <ArrowRight className="w-4 h-4" />
                        </a>
                    ) : (
                        <a
                            href="/admin/login"
                            className="flex items-center justify-center gap-2 bg-brand-gold hover:bg-brand-gold-light text-black font-bold px-4 py-3 rounded-xl transition text-sm"
                        >
                            <LogIn className="w-4 h-4" />
                            <span>Ingresar</span>
                        </a>
                    )}
                </div>
            </aside>
        </>
    );

    return (
        <>
            <button
                type="button"
                onClick={() => setOpen(true)}
                className={`md:hidden inline-flex items-center justify-center w-10 h-10 rounded-lg text-gray-200 hover:bg-white/10 hover:text-brand-gold transition ${className}`}
                aria-label="Abrir menú"
                aria-expanded={open}
            >
                <Menu className="w-6 h-6" />
            </button>

            {mounted && createPortal(drawer, document.body)}
        </>
    );
}
