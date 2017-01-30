import scala.io.Source

// scala countHap.scala aaa.hap aaa.sam
object countHap {

def parseSam(samLine: String): (String, String, List[(Int, Char)], Int) = { // queryname, refname, (idx, basecall), length

  def parseCIGAR(cigar: String): List[(Char, Int)] = {
    val rg = """([0-9]+)([MID])(.*)""".r
    val lb = scala.collection.mutable.ListBuffer.empty[(Char, Int)]

    @scala.annotation.tailrec
    def loop(c: String): Unit = {
      if (c.size > 0) { c match {
        case rg(d, c, rest) => { lb += ((c.head, d.toInt)); loop(rest) }
        case _ => println("unmatched: %s".format(c))
    }}}

    loop(cigar)
    return lb.result
  }

  val lb = scala.collection.mutable.ListBuffer.empty[(Int, Char)]
  var query_name = "None"
  var ref_name = "None"
  var seqlen = 0

  samLine.split("\t").toList match {
    case qname::_::rname::pos::mapq::cigar::_::_::tlen::seq::_ => {
      seqlen = seq.length
      query_name = qname
      ref_name = rname
      var refpos = pos.toInt
      var readpos = 0
      for ((c, i) <- parseCIGAR(cigar)) { c match {
        case 'M' => {
          for (ii <- 0 until i) lb += ((refpos+ii, seq(readpos+ii)))
          refpos += i; readpos += i
        }
        case 'I' => readpos += i;
        case 'D' => refpos += i;
        case _ => println("unrecognized cigar char: %c".format(c))
      }}
    }
    case _ => { println("ERROR: broken line: %s".format(samLine)) }
  }

  (query_name, ref_name, lb.result, seqlen)
}

// TODO: instead, can I use an implicit Ordering for T and(!) S ???
def zipBy[T,S](l1: List[T], l2: List[S], comp: (T,S) => Int): List[(T, S)] = { // T.idx - S.idx
  val lb = scala.collection.mutable.ListBuffer.empty[(T, S)]

  @scala.annotation.tailrec
  def loop(_l1: List[T], _l2: List[S]): Unit = {
    if (_l1.isEmpty || _l2.isEmpty) return
    else comp(_l1.head, _l2.head).signum match {
      case 1 => loop(_l1, _l2.tail)
      case -1 => loop(_l1.tail, _l2)
      case 0 => {
        lb += ((_l1.head, _l2.head)); loop(_l1.tail, _l2.tail)
      }
    }
  }

  loop(l1, l2)
  lb.result
}

def binom(a:Int, b: Int, p: Double): Double = {
  def fct(i: Int) = (2 to i).product
  val cmb = fct(a+b) * 1.0 / (fct(a)*fct(b))
  cmb * scala.math.pow(0.5, a+b)
}


// Here's entry point

def main(args: Array[String]) = {
  val hap_file = args(0)
  val sam_file = args(1)
  val out_file = new java.io.PrintWriter(new java.io.File(sam_file.replaceAll("sam", "counthap")))
  out_file.println("rname\tqname\tcount_left\tcount_right\tcount_other\tlength\n")

  val hap: Map[String, List[(String, Int, Char, Char)]] = Source.fromFile(hap_file).getLines.toList
    .map(_.split(" "))
    .filter(x => x(2).length<2 && x(3).length<2) // take only SNV
    .map(x => (x(0), x(1).toInt, x(2).head, x(3).head))
    .groupBy(x => x._1)

  var (count_ref, count_alt, count_other) = (0, 0, 0)
  var seqlen = 0
  var last_qname = ""
  var last_rname = ""
  var outline = ""

  for (read <- Source.fromFile(sam_file).getLines; if read.head != '@') {
    val (qname, rname, readVar, _seqlen) = parseSam(read)

    if (qname != last_qname) {
      outline = last_rname + "\t" + last_qname + "\t%d\t%d\t%d\t%d".format(count_ref, count_alt, count_other, seqlen)
      out_file.println(outline)
      count_ref = 0; count_alt = 0; count_other = 0; seqlen = 0;
    }

    if (hap.contains(rname)) {
      for ( ((s, i, r, a), (_, c)) <- zipBy(hap(rname), readVar, (x:(String, Int, Char, Char),y:(Int,Char)) => { x._2 - y._1 }) ) {
        if (c == r) count_ref += 1
        else if (c == a) count_alt += 1
        else count_other += 1
      }
    }
    seqlen += _seqlen
    last_qname = qname
    last_rname = rname
  }

  outline = last_rname + "\t" + last_qname + "\t%d\t%d\t%d\t%d".format(count_ref, count_alt, count_other, seqlen)
  out_file.println(outline)
  out_file.close

  println("exit countHap.scala")
}
} // end of object countHap
