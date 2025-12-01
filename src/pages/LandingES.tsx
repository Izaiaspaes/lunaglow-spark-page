import { Hero } from "@/components/landing/es/Hero";
import { Features } from "@/components/landing/es/Features";
import { Pricing } from "@/components/landing/es/Pricing";
import { Testimonials } from "@/components/landing/es/Testimonials";
import { FAQ } from "@/components/landing/es/FAQ";
import { FinalCTA } from "@/components/landing/es/FinalCTA";

const LandingES = () => {
  return (
    <div className="min-h-screen">
      <Hero />
      <Features />
      <Testimonials />
      <Pricing />
      <FAQ />
      <FinalCTA />
    </div>
  );
};

export default LandingES;
