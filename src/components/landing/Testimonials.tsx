import { Card } from "@/components/ui/card";
import { Star } from "lucide-react";
import { motion } from "framer-motion";

const testimonials = [
  {
    name: "Mariana S.",
    age: 28,
    text: "O Luna Glow mudou minha vida! Finalmente entendo meu corpo e consigo me planejar. A assistente IA é como ter uma amiga que sempre entende.",
    rating: 5,
    highlight: "Perdi 5kg seguindo os planos personalizados"
  },
  {
    name: "Julia R.",
    age: 32,
    text: "Depois de anos sofrendo com TPM, o Luna me ajudou a identificar padrões e antecipar sintomas. Agora sei exatamente o que fazer em cada fase.",
    rating: 5,
    highlight: "TPM 80% mais leve"
  },
  {
    name: "Carolina P.",
    age: 25,
    text: "O diário com IA é incrível! Ele conecta pontos que eu nunca havia percebido entre meu ciclo e minhas emoções. Me sinto muito mais no controle.",
    rating: 5,
    highlight: "100% mais autoconhecimento"
  }
];

export const Testimonials = () => {
  return (
    <section className="py-24 bg-background">
      <div className="container mx-auto px-4">
        <motion.div 
          className="text-center max-w-3xl mx-auto mb-16"
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <h2 className="text-4xl md:text-5xl font-bold mb-6">
            Histórias de{" "}
            <span className="gradient-text">transformação</span>
          </h2>
          <p className="text-xl text-muted-foreground">
            Veja como o Luna Glow está ajudando mulheres a viverem melhor
          </p>
        </motion.div>

        <div className="grid md:grid-cols-3 gap-8 max-w-7xl mx-auto">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.2 }}
            >
              <Card className="p-8 space-y-4 hover:shadow-xl transition-shadow border-2 hover:border-primary/20 h-full">
              <div className="flex gap-1">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <Star key={i} className="w-5 h-5 fill-primary text-primary" />
                ))}
              </div>
              
              <p className="text-foreground/90 leading-relaxed">"{testimonial.text}"</p>
              
              <div className="pt-4 border-t border-border space-y-2">
                <div className="font-semibold">{testimonial.name}</div>
                <div className="text-sm text-muted-foreground">{testimonial.age} anos</div>
                <div className="inline-block bg-primary/10 text-primary text-xs font-medium px-3 py-1 rounded-full">
                  {testimonial.highlight}
                </div>
              </div>
              </Card>
            </motion.div>
          ))}
        </div>

        <motion.div 
          className="text-center mt-12"
          initial={{ opacity: 0, scale: 0.9 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.5 }}
        >
          <div className="inline-flex items-center gap-2 bg-secondary px-6 py-3 rounded-full">
            <div className="flex -space-x-2">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="w-8 h-8 rounded-full bg-primary/20 border-2 border-background" />
              ))}
            </div>
            <span className="text-sm font-medium">
              Junte-se a <span className="text-primary font-bold">500+ mulheres</span> que já transformaram seu bem-estar
            </span>
          </div>
        </motion.div>
      </div>
    </section>
  );
};
