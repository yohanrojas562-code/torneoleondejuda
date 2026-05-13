import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { motion } from 'framer-motion';
import { X } from 'lucide-react';

export interface PlayerTeamRef {
    id: number;
    name: string;
    short_name: string | null;
    logo: string | null;
    primary_color: string | null;
}

export interface PlayerProfile {
    id: number;
    first_name: string;
    last_name: string;
    photo: string | null;
    jersey_number: number | null;
    position: string | null;
    church: string | null;
    team: PlayerTeamRef | null;
    stats: {
        goals: number;
        matches: number;
        yellow_cards: number;
        blue_cards: number;
        red_cards: number;
    };
}

function TeamLogo({ team, size = 24 }: { team: PlayerTeamRef | null; size?: number }) {
    if (!team) return null;
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
            style={{
                width: size,
                height: size,
                backgroundColor: team.primary_color || '#D68F03',
                fontSize: size * 0.4,
            }}
        >
            {team.name.charAt(0)}
        </div>
    );
}

function StatCell({
    value,
    label,
    color = 'default',
}: {
    value: number;
    label: string;
    color?: 'default' | 'gold' | 'yellow' | 'blue' | 'red';
}) {
    const colorClass = {
        default: 'text-white',
        gold: 'text-brand-gold',
        yellow: 'text-yellow-400',
        blue: 'text-blue-400',
        red: 'text-red-400',
    }[color];

    return (
        <div className="bg-white/[0.03] border border-white/10 rounded-lg py-2.5 text-center">
            <p className={`text-xl font-extrabold ${colorClass}`}>{value}</p>
            <p className="text-gray-500 text-[10px] uppercase tracking-wider mt-0.5">{label}</p>
        </div>
    );
}

export default function PlayerModal({
    player,
    onClose,
}: {
    player: PlayerProfile;
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

    const fullName = `${player.first_name} ${player.last_name}`;
    const initial = (player.first_name?.charAt(0) || player.last_name?.charAt(0) || '?').toUpperCase();

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
                aria-label={`Perfil de ${fullName}`}
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
                    {player.photo ? (
                        <img
                            src={`/storage/${player.photo}`}
                            alt={fullName}
                            className="w-full h-full object-cover"
                        />
                    ) : (
                        <div
                            className="w-full h-full flex items-center justify-center"
                            style={{
                                backgroundColor: player.team?.primary_color ? `${player.team.primary_color}33` : 'rgba(214,143,3,0.1)',
                            }}
                        >
                            <span
                                className="font-extrabold text-[8rem] leading-none"
                                style={{ color: player.team?.primary_color || '#D68F03' }}
                            >
                                {initial}
                            </span>
                        </div>
                    )}
                    {player.jersey_number != null && (
                        <div className="absolute top-4 left-4 inline-flex items-center justify-center min-w-[3rem] h-12 px-3 rounded-xl bg-brand-gold text-black font-extrabold text-xl shadow-lg">
                            #{player.jersey_number}
                        </div>
                    )}
                    <div className="absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-brand-black to-transparent pointer-events-none" />
                </div>

                <div className="px-6 pb-7 pt-5">
                    <div className="text-center">
                        <h3 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">{fullName}</h3>
                        {player.team && (
                            <div className="flex items-center justify-center gap-2 mt-3">
                                <TeamLogo team={player.team} size={24} />
                                <span className="text-gray-300 font-semibold text-sm">{player.team.name}</span>
                            </div>
                        )}
                    </div>

                    {(player.position || player.church) && (
                        <div className="grid grid-cols-2 gap-2.5 mt-5">
                            {player.position && (
                                <div className="bg-white/[0.03] border border-white/10 rounded-xl p-3 text-center">
                                    <p className="text-gray-500 text-[10px] uppercase tracking-wider">Posición</p>
                                    <p className="text-white font-semibold text-sm mt-1 capitalize">{player.position}</p>
                                </div>
                            )}
                            {player.church && (
                                <div className="bg-white/[0.03] border border-white/10 rounded-xl p-3 text-center">
                                    <p className="text-gray-500 text-[10px] uppercase tracking-wider">Iglesia</p>
                                    <p className="text-white font-semibold text-sm mt-1">{player.church}</p>
                                </div>
                            )}
                        </div>
                    )}

                    <div className="mt-6 pt-5 border-t border-white/10">
                        <p className="text-brand-gold text-[11px] font-bold uppercase tracking-[0.2em] text-center mb-3">Estadísticas</p>
                        <div className="grid grid-cols-5 gap-2">
                            <StatCell value={player.stats.goals} label="Goles" color="gold" />
                            <StatCell value={player.stats.matches} label="PJ" />
                            <StatCell value={player.stats.yellow_cards} label="TA" color="yellow" />
                            <StatCell value={player.stats.blue_cards} label="TAz" color="blue" />
                            <StatCell value={player.stats.red_cards} label="TR" color="red" />
                        </div>
                    </div>
                </div>
            </motion.div>
        </div>,
        document.body
    );
}
