import React, { useState, useEffect, useRef, useCallback } from 'react';
import { motion, useScroll, useTransform, useSpring, useInView, AnimatePresence } from 'framer-motion';

/**
 * ========================================
 * Apple風ミニマルLP - フルアニメーション版
 * ========================================
 * 
 * 使用技術:
 * - React + Framer Motion
 * - カスタムフック(useInView, useScroll, useTransform)
 * - パララックス効果
 * - 文字単位アニメーション
 * - マウス追従エフェクト
 * - スムーズスクロール
 * - ローディングアニメーション
 */

// ========================================
// カスタムカーソルコンポーネント
// ========================================
const CustomCursor = () => {
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const [isHovering, setIsHovering] = useState(false);

  useEffect(() => {
    const updateMousePosition = (e) => {
      setMousePosition({ x: e.clientX, y: e.clientY });
    };

    const handleMouseOver = (e) => {
      if (e.target.closest('a, button, .hoverable')) {
        setIsHovering(true);
      } else {
        setIsHovering(false);
      }
    };

    window.addEventListener('mousemove', updateMousePosition);
    window.addEventListener('mouseover', handleMouseOver);

    return () => {
      window.removeEventListener('mousemove', updateMousePosition);
      window.removeEventListener('mouseover', handleMouseOver);
    };
  }, []);

  return (
    <>
      {/* メインカーソル */}
      <motion.div
        className="fixed top-0 left-0 w-4 h-4 bg-black rounded-full pointer-events-none z-[9999] mix-blend-difference"
        animate={{
          x: mousePosition.x - 8,
          y: mousePosition.y - 8,
          scale: isHovering ? 2.5 : 1,
        }}
        transition={{ type: 'spring', stiffness: 500, damping: 28 }}
      />
      {/* トレイルカーソル */}
      <motion.div
        className="fixed top-0 left-0 w-10 h-10 border border-black/30 rounded-full pointer-events-none z-[9998]"
        animate={{
          x: mousePosition.x - 20,
          y: mousePosition.y - 20,
          scale: isHovering ? 1.5 : 1,
        }}
        transition={{ type: 'spring', stiffness: 150, damping: 15 }}
      />
    </>
  );
};

// ========================================
// ローディング画面コンポーネント
// ========================================
const LoadingScreen = ({ onComplete }) => {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval);
          setTimeout(onComplete, 500);
          return 100;
        }
        return prev + 2;
      });
    }, 30);

    return () => clearInterval(interval);
  }, [onComplete]);

  return (
    <motion.div
      className="fixed inset-0 bg-white z-[10000] flex flex-col items-center justify-center"
      exit={{ opacity: 0, y: -50 }}
      transition={{ duration: 0.8, ease: [0.76, 0, 0.24, 1] }}
    >
      {/* ロゴアニメーション */}
      <motion.div
        initial={{ scale: 0.8, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.5 }}
        className="text-4xl font-semibold tracking-tight mb-12"
      >
        Minimal.
      </motion.div>
      
      {/* プログレスバー */}
      <div className="w-48 h-[2px] bg-gray-200 rounded-full overflow-hidden">
        <motion.div
          className="h-full bg-black rounded-full"
          initial={{ width: 0 }}
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.1 }}
        />
      </div>
      
      {/* パーセント表示 */}
      <motion.p
        className="mt-4 text-sm text-gray-400 font-medium"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.3 }}
      >
        {progress}%
      </motion.p>
    </motion.div>
  );
};

// ========================================
// スクロールプログレスバー
// ========================================
const ScrollProgress = () => {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, { stiffness: 100, damping: 30 });

  return (
    <motion.div
      className="fixed top-0 left-0 right-0 h-[3px] bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 origin-left z-[1001]"
      style={{ scaleX }}
    />
  );
};

// ========================================
// 文字単位アニメーションコンポーネント
// ========================================
const AnimatedText = ({ text, className = '', delay = 0 }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  const words = text.split(' ');

  const container = {
    hidden: { opacity: 0 },
    visible: (i = 1) => ({
      opacity: 1,
      transition: { staggerChildren: 0.12, delayChildren: delay },
    }),
  };

  const child = {
    hidden: { opacity: 0, y: 50, rotateX: -90 },
    visible: {
      opacity: 1,
      y: 0,
      rotateX: 0,
      transition: {
        type: 'spring',
        damping: 12,
        stiffness: 100,
      },
    },
  };

  return (
    <motion.div
      ref={ref}
      className={`overflow-hidden ${className}`}
      variants={container}
      initial="hidden"
      animate={isInView ? 'visible' : 'hidden'}
    >
      {words.map((word, index) => (
        <motion.span
          key={index}
          className="inline-block mr-[0.25em]"
          variants={child}
          style={{ perspective: 1000 }}
        >
          {word}
        </motion.span>
      ))}
    </motion.div>
  );
};

// ========================================
// 1文字ずつアニメーションするテキスト
// ========================================
const CharacterAnimation = ({ text, className = '' }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-50px' });

  return (
    <motion.div ref={ref} className={className}>
      {text.split('').map((char, index) => (
        <motion.span
          key={index}
          initial={{ opacity: 0, y: 100 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{
            duration: 0.5,
            delay: index * 0.03,
            ease: [0.215, 0.61, 0.355, 1],
          }}
          className="inline-block"
        >
          {char === ' ' ? '\u00A0' : char}
        </motion.span>
      ))}
    </motion.div>
  );
};

// ========================================
// パララックス画像コンポーネント
// ========================================
const ParallaxImage = ({ children, speed = 0.5 }) => {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'end start'],
  });

  const y = useTransform(scrollYProgress, [0, 1], [100 * speed, -100 * speed]);
  const scale = useTransform(scrollYProgress, [0, 0.5, 1], [0.8, 1, 0.8]);
  const opacity = useTransform(scrollYProgress, [0, 0.3, 0.7, 1], [0, 1, 1, 0]);

  return (
    <motion.div
      ref={ref}
      style={{ y, scale, opacity }}
      className="will-change-transform"
    >
      {children}
    </motion.div>
  );
};

// ========================================
// 3D傾きカードコンポーネント
// ========================================
const TiltCard = ({ children, className = '' }) => {
  const ref = useRef(null);
  const [rotateX, setRotateX] = useState(0);
  const [rotateY, setRotateY] = useState(0);

  const handleMouseMove = (e) => {
    if (!ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    const mouseX = e.clientX - centerX;
    const mouseY = e.clientY - centerY;
    
    setRotateX(-mouseY / 20);
    setRotateY(mouseX / 20);
  };

  const handleMouseLeave = () => {
    setRotateX(0);
    setRotateY(0);
  };

  return (
    <motion.div
      ref={ref}
      className={`${className} hoverable`}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      animate={{ rotateX, rotateY }}
      transition={{ type: 'spring', stiffness: 300, damping: 30 }}
      style={{ perspective: 1000, transformStyle: 'preserve-3d' }}
    >
      {children}
    </motion.div>
  );
};

// ========================================
// マグネットボタンコンポーネント
// ========================================
const MagneticButton = ({ children, className = '' }) => {
  const ref = useRef(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleMouse = (e) => {
    const { clientX, clientY } = e;
    const { left, top, width, height } = ref.current.getBoundingClientRect();
    const x = (clientX - left - width / 2) * 0.3;
    const y = (clientY - top - height / 2) * 0.3;
    setPosition({ x, y });
  };

  const reset = () => setPosition({ x: 0, y: 0 });

  return (
    <motion.button
      ref={ref}
      className={`${className} hoverable relative overflow-hidden`}
      onMouseMove={handleMouse}
      onMouseLeave={reset}
      animate={{ x: position.x, y: position.y }}
      transition={{ type: 'spring', stiffness: 150, damping: 15 }}
    >
      {children}
      <motion.div
        className="absolute inset-0 bg-black/5"
        initial={{ scale: 0, opacity: 0 }}
        whileHover={{ scale: 1, opacity: 1 }}
        transition={{ duration: 0.3 }}
        style={{ borderRadius: 'inherit' }}
      />
    </motion.button>
  );
};

// ========================================
// 画像プレースホルダーコンポーネント
// ========================================
const ImagePlaceholder = ({ text, className = '' }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <motion.div
      ref={ref}
      className={`bg-gradient-to-br from-gray-100 to-gray-200 rounded-3xl flex items-center justify-center overflow-hidden relative ${className}`}
      initial={{ opacity: 0, scale: 0.8, rotateY: -15 }}
      animate={isInView ? { opacity: 1, scale: 1, rotateY: 0 } : {}}
      transition={{ duration: 0.8, ease: [0.215, 0.61, 0.355, 1] }}
      whileHover={{ scale: 1.02 }}
    >
      {/* 装飾的なグラデーションオーバーレイ */}
      <motion.div
        className="absolute inset-0 bg-gradient-to-tr from-blue-500/10 via-purple-500/10 to-pink-500/10"
        animate={{
          background: [
            'linear-gradient(to top right, rgba(59,130,246,0.1), rgba(168,85,247,0.1), rgba(236,72,153,0.1))',
            'linear-gradient(to top right, rgba(236,72,153,0.1), rgba(59,130,246,0.1), rgba(168,85,247,0.1))',
            'linear-gradient(to top right, rgba(168,85,247,0.1), rgba(236,72,153,0.1), rgba(59,130,246,0.1))',
          ],
        }}
        transition={{ duration: 5, repeat: Infinity, ease: 'linear' }}
      />
      
      {/* フローティングシェイプ */}
      <motion.div
        className="absolute w-32 h-32 bg-white/30 rounded-full blur-2xl"
        animate={{
          x: [0, 50, 0],
          y: [0, -30, 0],
        }}
        transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
      />
      
      <span className="text-gray-400 font-medium z-10">{text}</span>
    </motion.div>
  );
};

// ========================================
// ナビゲーションコンポーネント
// ========================================
const Navigation = () => {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 50);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const navItems = ['Features', 'Design', 'Technology', 'Contact'];

  return (
    <motion.nav
      className="fixed top-0 left-0 right-0 z-[1000]"
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      transition={{ duration: 0.8, delay: 2 }}
    >
      <motion.div
        className="backdrop-blur-xl border-b transition-all duration-300"
        animate={{
          backgroundColor: scrolled ? 'rgba(255,255,255,0.9)' : 'rgba(255,255,255,0)',
          borderColor: scrolled ? 'rgba(0,0,0,0.05)' : 'rgba(0,0,0,0)',
        }}
      >
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <motion.a
            href="#"
            className="text-xl font-semibold tracking-tight hoverable"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Minimal.
          </motion.a>
          
          <ul className="hidden md:flex items-center gap-8">
            {navItems.map((item, index) => (
              <motion.li
                key={item}
                initial={{ opacity: 0, y: -20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 2.2 + index * 0.1 }}
              >
                <motion.a
                  href={`#${item.toLowerCase()}`}
                  className="text-sm font-medium text-gray-600 hover:text-black transition-colors hoverable relative"
                  whileHover={{ y: -2 }}
                >
                  {item}
                  <motion.span
                    className="absolute -bottom-1 left-0 right-0 h-[2px] bg-black"
                    initial={{ scaleX: 0 }}
                    whileHover={{ scaleX: 1 }}
                    transition={{ duration: 0.2 }}
                  />
                </motion.a>
              </motion.li>
            ))}
          </ul>
        </div>
      </motion.div>
    </motion.nav>
  );
};

// ========================================
// ヒーローセクション
// ========================================
const HeroSection = () => {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start start', 'end start'],
  });

  const y = useTransform(scrollYProgress, [0, 1], [0, 200]);
  const opacity = useTransform(scrollYProgress, [0, 0.5], [1, 0]);
  const scale = useTransform(scrollYProgress, [0, 0.5], [1, 0.9]);

  return (
    <motion.section
      ref={ref}
      className="min-h-screen flex flex-col items-center justify-center px-6 pt-24 relative overflow-hidden"
      style={{ opacity }}
    >
      {/* 背景のアニメーション装飾 */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(5)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-96 h-96 rounded-full opacity-30"
            style={{
              background: `radial-gradient(circle, ${
                ['#3b82f6', '#8b5cf6', '#ec4899', '#06b6d4', '#10b981'][i]
              }20, transparent)`,
              left: `${[10, 60, 30, 70, 20][i]}%`,
              top: `${[20, 40, 60, 10, 80][i]}%`,
            }}
            animate={{
              x: [0, 30, 0],
              y: [0, -20, 0],
              scale: [1, 1.2, 1],
            }}
            transition={{
              duration: 8 + i * 2,
              repeat: Infinity,
              ease: 'easeInOut',
              delay: i * 0.5,
            }}
          />
        ))}
      </div>

      <motion.div className="relative z-10 text-center" style={{ y, scale }}>
        {/* メインヘッドライン */}
        <CharacterAnimation
          text="シンプルの先へ。"
          className="text-5xl md:text-7xl lg:text-8xl font-semibold tracking-tight mb-6"
        />

        {/* サブヘッドライン */}
        <AnimatedText
          text="余計なものを削ぎ落とし、本質だけを残す。それが私たちの考えるデザインです。"
          className="text-xl md:text-2xl text-gray-500 max-w-2xl mx-auto mb-12"
          delay={0.5}
        />

        {/* CTAボタン */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.5, duration: 0.6 }}
        >
          <MagneticButton className="px-8 py-4 bg-black text-white rounded-full text-lg font-medium">
            体験する
          </MagneticButton>
        </motion.div>

        {/* ヒーロー画像 */}
        <motion.div
          className="mt-16 w-full max-w-4xl mx-auto"
          initial={{ opacity: 0, y: 100, rotateX: 45 }}
          animate={{ opacity: 1, y: 0, rotateX: 0 }}
          transition={{ delay: 1, duration: 1, ease: [0.215, 0.61, 0.355, 1] }}
          style={{ perspective: 1000 }}
        >
          <TiltCard>
            <ImagePlaceholder text="Hero Image" className="aspect-video w-full" />
          </TiltCard>
        </motion.div>
      </motion.div>

      {/* スクロールインジケーター */}
      <motion.div
        className="absolute bottom-8 left-1/2 -translate-x-1/2"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2 }}
      >
        <motion.div
          className="w-6 h-10 border-2 border-gray-300 rounded-full flex justify-center pt-2"
          animate={{ y: [0, 5, 0] }}
          transition={{ duration: 1.5, repeat: Infinity }}
        >
          <motion.div
            className="w-1.5 h-1.5 bg-gray-400 rounded-full"
            animate={{ y: [0, 12, 0], opacity: [1, 0, 1] }}
            transition={{ duration: 1.5, repeat: Infinity }}
          />
        </motion.div>
      </motion.div>
    </motion.section>
  );
};

// ========================================
// フィーチャーセクション
// ========================================
const FeatureSection = ({ id, title, subtitle, description, reverse = false, bgGray = false }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <section
      id={id}
      ref={ref}
      className={`min-h-screen flex items-center py-24 px-6 ${bgGray ? 'bg-gray-50' : ''}`}
    >
      <div className="max-w-6xl mx-auto w-full">
        <div className={`grid md:grid-cols-2 gap-16 items-center ${reverse ? 'md:flex md:flex-row-reverse' : ''}`}>
          {/* テキストコンテンツ */}
          <motion.div
            className="space-y-6"
            initial={{ opacity: 0, x: reverse ? 60 : -60 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8, ease: [0.215, 0.61, 0.355, 1] }}
          >
            <AnimatedText
              text={title}
              className="text-4xl md:text-5xl lg:text-6xl font-semibold tracking-tight leading-tight"
            />
            
            <motion.p
              className="text-xl md:text-2xl text-gray-500"
              initial={{ opacity: 0, y: 20 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ delay: 0.3, duration: 0.6 }}
            >
              {subtitle}
            </motion.p>
            
            <motion.p
              className="text-lg text-gray-600 leading-relaxed"
              initial={{ opacity: 0, y: 20 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ delay: 0.4, duration: 0.6 }}
            >
              {description}
            </motion.p>
            
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={isInView ? { opacity: 1, y: 0 } : {}}
              transition={{ delay: 0.5, duration: 0.6 }}
            >
              <motion.a
                href="#"
                className="inline-flex items-center gap-2 text-lg text-blue-600 font-medium hoverable"
                whileHover={{ x: 5 }}
              >
                詳しく見る
                <motion.span
                  animate={{ x: [0, 5, 0] }}
                  transition={{ duration: 1, repeat: Infinity }}
                >
                  →
                </motion.span>
              </motion.a>
            </motion.div>
          </motion.div>

          {/* 画像 */}
          <motion.div
            initial={{ opacity: 0, x: reverse ? -60 : 60 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.8, ease: [0.215, 0.61, 0.355, 1], delay: 0.2 }}
          >
            <ParallaxImage>
              <TiltCard>
                <ImagePlaceholder
                  text={`${title.replace(/\n/g, ' ')} Image`}
                  className="aspect-[4/3] w-full"
                />
              </TiltCard>
            </ParallaxImage>
          </motion.div>
        </div>
      </div>
    </section>
  );
};

// ========================================
// 数字カウントアップコンポーネント
// ========================================
const CountUp = ({ end, duration = 2, suffix = '' }) => {
  const [count, setCount] = useState(0);
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true });

  useEffect(() => {
    if (!isInView) return;

    let startTime;
    const animate = (timestamp) => {
      if (!startTime) startTime = timestamp;
      const progress = Math.min((timestamp - startTime) / (duration * 1000), 1);
      setCount(Math.floor(progress * end));
      if (progress < 1) requestAnimationFrame(animate);
    };

    requestAnimationFrame(animate);
  }, [isInView, end, duration]);

  return (
    <span ref={ref}>
      {count}
      {suffix}
    </span>
  );
};

// ========================================
// 統計セクション
// ========================================
const StatsSection = () => {
  const stats = [
    { value: 99, suffix: '%', label: '顧客満足度' },
    { value: 50, suffix: 'M+', label: 'ダウンロード数' },
    { value: 24, suffix: '/7', label: 'サポート対応' },
    { value: 150, suffix: '+', label: '受賞歴' },
  ];

  return (
    <section className="py-24 px-6 bg-black text-white overflow-hidden">
      <div className="max-w-6xl mx-auto">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <h2 className="text-4xl md:text-5xl font-semibold mb-4">
            数字が語る実績
          </h2>
          <p className="text-xl text-gray-400">
            私たちの成果をご覧ください
          </p>
        </motion.div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
          {stats.map((stat, index) => (
            <motion.div
              key={stat.label}
              className="text-center"
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1, duration: 0.6 }}
            >
              <div className="text-5xl md:text-6xl font-bold mb-2 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 bg-clip-text text-transparent">
                <CountUp end={stat.value} suffix={stat.suffix} />
              </div>
              <div className="text-gray-400">{stat.label}</div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

// ========================================
// テスティモニアルセクション
// ========================================
const TestimonialsSection = () => {
  const testimonials = [
    {
      quote: '革新的なデザインと直感的な操作性。まさに次世代のプロダクトです。',
      author: '田中 太郎',
      role: 'デザイナー',
    },
    {
      quote: 'シンプルでありながら、必要な機能はすべて揃っている。完璧なバランス。',
      author: '鈴木 花子',
      role: 'エンジニア',
    },
    {
      quote: 'このプロダクトのおかげで、私たちのワークフローが劇的に改善されました。',
      author: '佐藤 次郎',
      role: 'プロダクトマネージャー',
    },
  ];

  return (
    <section className="py-24 px-6">
      <div className="max-w-6xl mx-auto">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <h2 className="text-4xl md:text-5xl font-semibold mb-4">
            お客様の声
          </h2>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-8">
          {testimonials.map((item, index) => (
            <motion.div
              key={index}
              className="p-8 bg-gray-50 rounded-3xl"
              initial={{ opacity: 0, y: 40, rotateX: -10 }}
              whileInView={{ opacity: 1, y: 0, rotateX: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.15, duration: 0.6 }}
              whileHover={{ y: -10, boxShadow: '0 20px 40px rgba(0,0,0,0.1)' }}
            >
              <p className="text-lg text-gray-600 mb-6 leading-relaxed">
                "{item.quote}"
              </p>
              <div>
                <div className="font-semibold">{item.author}</div>
                <div className="text-sm text-gray-400">{item.role}</div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

// ========================================
// CTAセクション
// ========================================
const CTASection = () => {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'end start'],
  });

  const backgroundY = useTransform(scrollYProgress, [0, 1], ['0%', '30%']);

  return (
    <section
      ref={ref}
      id="contact"
      className="relative py-32 px-6 overflow-hidden bg-gradient-to-br from-gray-900 via-gray-800 to-black"
    >
      {/* 背景アニメーション */}
      <motion.div
        className="absolute inset-0"
        style={{ y: backgroundY }}
      >
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-2 h-2 bg-white/10 rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
            }}
            animate={{
              y: [0, -100],
              opacity: [0, 1, 0],
            }}
            transition={{
              duration: 3 + Math.random() * 2,
              repeat: Infinity,
              delay: Math.random() * 2,
            }}
          />
        ))}
      </motion.div>

      <div className="relative z-10 max-w-4xl mx-auto text-center">
        <CharacterAnimation
          text="始めよう。"
          className="text-5xl md:text-7xl font-semibold text-white mb-6"
        />
        
        <AnimatedText
          text="新しい体験への第一歩を。私たちと一緒に、未来を創りましょう。"
          className="text-xl md:text-2xl text-gray-400 mb-12"
          delay={0.3}
        />

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 0.6 }}
        >
          <MagneticButton className="px-10 py-5 bg-white text-black rounded-full text-xl font-medium">
            お問い合わせ
          </MagneticButton>
        </motion.div>
      </div>
    </section>
  );
};

// ========================================
// フッター
// ========================================
const Footer = () => {
  return (
    <footer className="py-8 px-6 bg-gray-50 border-t border-gray-100">
      <motion.div
        className="max-w-6xl mx-auto text-center"
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
      >
        <p className="text-sm text-gray-400">
          © 2025 Minimal. All rights reserved.
        </p>
      </motion.div>
    </footer>
  );
};

// ========================================
// メインアプリケーション
// ========================================
export default function App() {
  const [isLoading, setIsLoading] = useState(true);

  const handleLoadingComplete = useCallback(() => {
    setIsLoading(false);
  }, []);

  return (
    <div className="cursor-none">
      {/* カスタムカーソル */}
      <CustomCursor />

      {/* スクロールプログレスバー */}
      {!isLoading && <ScrollProgress />}

      {/* ローディング画面 */}
      <AnimatePresence mode="wait">
        {isLoading && <LoadingScreen onComplete={handleLoadingComplete} />}
      </AnimatePresence>

      {/* メインコンテンツ */}
      <AnimatePresence>
        {!isLoading && (
          <motion.main
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.5 }}
          >
            <Navigation />
            <HeroSection />
            
            <FeatureSection
              id="features"
              title="直感的な体験を。"
              subtitle="複雑な操作は必要ありません。触れた瞬間から、すべてが自然に理解できます。"
              description="私たちは、テクノロジーは人に寄り添うべきだと考えています。だからこそ、インターフェースのすべての要素が、あなたの思考の流れに沿って配置されています。"
            />

            <FeatureSection
              id="design"
              title="美しさは細部に宿る。"
              subtitle="1ピクセルの妥協も許さない。それが、私たちのクラフトマンシップです。"
              description="素材の選定から、角の丸み、文字の間隔まで。目に見えない部分こそ、最も大切にしています。完璧を追求することで、製品は芸術になります。"
              reverse
              bgGray
            />

            <StatsSection />

            <FeatureSection
              id="technology"
              title="革新的なテクノロジー。"
              subtitle="最先端の技術を、シームレスに。見えないところで、あなたの毎日を支えます。"
              description="パフォーマンス、効率性、持続可能性。すべてを両立させるために、私たちは独自のアーキテクチャを開発しました。テクノロジーの限界を、常に押し広げています。"
            />

            <TestimonialsSection />
            <CTASection />
            <Footer />
          </motion.main>
        )}
      </AnimatePresence>

      {/* グローバルスタイル */}
      <style>{`
        @media (max-width: 768px) {
          .cursor-none {
            cursor: auto;
          }
          .cursor-none > div:first-child,
          .cursor-none > div:nth-child(2) {
            display: none;
          }
        }

        /* スムーズスクロール */
        html {
          scroll-behavior: smooth;
        }

        /* セレクション */
        ::selection {
          background: rgba(59, 130, 246, 0.3);
        }
      `}</style>
    </div>
  );
}
