class Cerveza {
	const property lupulo
	const property origen
	const property precioPorLitro
	
	method graduacion()
}

class Rubia inherits Cerveza {
	var property graduacion
}

class Negra inherits Cerveza {
	override method graduacion() = 0.04.min(lupulo * 2)
}

class Roja inherits Negra {
	override method graduacion() = super() * 1.25
}

class Jarra {
	const property capacidadJarra
	const property marca = new Negra(lupulo = 0.03, origen = "arg", precioPorLitro = 400)
	var property carpa
	
	method contenidoAlcohol() = capacidadJarra * marca.graduacion()
	
	method precioDeLaVenta() = capacidadJarra * marca.precioPorLitro() * carpa.recargo().recargo(carpa)
}

class Persona {
	var property jarrasCompradas = []
	var property peso
	var property musicaTradicional
	var property aguante
	
	const property nacionalidad
	
	method comprarCerveza(cerveza) = jarrasCompradas.add(cerveza)
	
	method totalAlcohol() {
		return jarrasCompradas.sum({
			c => c.contenidoAlcohol()
		})
	}
	
	method estaEbria() = self.totalAlcohol() * peso > aguante
	
	method leGusta(cerveza)
	
	method quiereEntrar(carpa) {
		return self.leGusta(carpa.marcaCerveza()) and self.musicaTradicional() == carpa.tieneBanda()
	}
	
	method ingresar(carpa) {
		if (self.puedeEntrar(carpa)) {
			carpa.ingresar(self)
		} else {
			self.error("La persona no puede entrar en la carpa")
		}
	}
	
	method puedeEntrar(carpa) {
		return self.quiereEntrar(carpa) and carpa.dejaIngresar(self) 
	}
	
	 method jarrasConMasDe1Litro() {
    	return jarrasCompradas.all({
    		c => c.capacidadJarra() >= 1
    	})
    }
    
    method esPatriota() {
    	return jarrasCompradas.all({
    		c => c.marca().origen() == nacionalidad
    	})
    }
    
    method marcaDeJarrasCompradas() {
    	return jarrasCompradas.map({
    		c => c.marca()
    	}).asSet()
    }
    
    method esCompatibleCon(persona) {
    	if (self.lasJarrasDeUno(persona) == 0 or self.lasJarrasDeOtro(persona) == 0) {
    		return false
    	} else {
    		return (self.lasJarrasDeUno(persona) / self.lasJarrasDeOtro(persona)) <= 2
    	}
  	}
    
    method lasJarrasDeUno(persona) {
    	return self.marcaDeJarrasCompradas().size()
    }
    
    method lasJarrasDeOtro(persona) {
    	return self.marcaDeJarrasCompradas().intersection(persona.marcaDeJarrasCompradas()).size()
    }
    
    method carpasDondeSeTomo() {
    	return jarrasCompradas.map({
    		c => c.carpa()
    	}).asSet()
    }
    
    method listaDelitrosTomados() {
    	return jarrasCompradas.map({c => c.capacidadJarra()})
    } 
    
    method estaEnVicio() {
		if (self.listaDelitrosTomados().size() == 0 or self.listaDelitrosTomados().size() == 1) {
			return false
		} else {
			return self.listaDelitrosTomados().get(self.listaDelitrosTomados().size() - 2) <= self.listaDelitrosTomados().last() 
		}
	}
	
	method gastoTotalCerveza() {
		return jarrasCompradas.sum({
			c => c.precioDeLaVenta()
		})
	}
	
	method jarraMasCara() {
		return jarrasCompradas.max({
			c => c.precioDeLaVenta()
		})
	}
}

class Belga inherits Persona {
	override method leGusta(cerveza) = cerveza.lupulo() > 0.04
}

class Checo inherits Persona {
	override method leGusta(cerveza) = cerveza.graduacion() > 0.08
}

class Aleman inherits Persona {
	override method leGusta(cerveza) = true
}

class Carpa  {
    var property capacidadDeCarpa
    var property tieneBanda
    var property personasDentro = []
    var property recargo
    
    const property marcaCerveza

    method limiteMaxDeCarpa() {
        return capacidadDeCarpa == 40
    }
    
    method ingresar(persona) {
    	personasDentro.add(persona)
    }
    
    method carpaEsPar() {
    	return personasDentro.size().even()
    }
    
    method dejaIngresar(persona) {
    	return capacidadDeCarpa > personasDentro.size() and not persona.estaEbria()
    }
    
    method servirCerveza(persona, litros) {
    	if (personasDentro.contains(persona)) {
    		persona.comprarCerveza(new Jarra(capacidadJarra = litros, marca = marcaCerveza, carpa = self))
    	} else {
    		self.error("La persona no está en la carpa")
    	}
    }
    
    method ebriosEmpedernidos() {
    	return personasDentro.count({
    		p => p.estaEbria() and p.jarrasConMasDe1Litro()
    	})
    }
    
    method esHomogenea() {
    	return personasDentro.map({
    		p => p.nacionalidad()
    	}).asSet().size() == 1
    }
    
    method clientesSinServir() {
    	return personasDentro.filter({
    		p => not p.carpasDondeSeTomo().contains(self)
    	})
    }  
}

object recargoFijo {
	
   	method recargo(carpa) = 1.30
}

object recargoPorCantidad {
	
	method recargo(carpa) {
		if(carpa.capacidadDeCarpa() == 0 or carpa.personasDentro().size() == 0) {
			return 1
		} else if (carpa.capacidadDeCarpa() / carpa.personasDentro().size() <= 2) {
			return 1.40
		} else {
			return 1.25
		}
	}
} 

object recargoPorEbriedad {
	
	method recargo(carpa) {
		const personasEbrias = carpa.personasDentro().count({p => p.estaEbria()})
		
		if (personasEbrias == 0 or carpa.personasDentro().size() == 0) {
			return 1
		} else if (personasEbrias >= carpa.personasDentro().size() * 0.75) {
			return 1.50
		} else {
			return 1.20
		}
	}
	
} 