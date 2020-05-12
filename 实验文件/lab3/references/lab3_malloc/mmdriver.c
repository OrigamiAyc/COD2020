#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <assert.h>
#include <float.h>

#include "mm.h"
#include "memlib.h"

/* Misc */
#define MAXLINE 1024	   /* max string size */
#define HDRLINES 4		   /* number of header lines in a trace file */
#define LINENUM(i) (i + 5) /* cnvt trace request nums to linenums (origin 1) */
/* 
 * Alignment requirement in bytes (either 4 or 8) 
 */
#define ALIGNMENT 8

/* Returns true if p is ALIGNMENT-byte aligned */
#define IS_ALIGNED(p) ((((unsigned int)(p)) % ALIGNMENT) == 0)

/********************
 * Global variables
 *******************/
int verbose = 0;	   /* global flag for verbose output */
static int errors = 0; /* number of errs found when running student malloc */
char msg[MAXLINE];	 /* for whenever we need to compose an error message */

/****************************** 
 * The key compound data types 
 *****************************/

/* Records the extent of each block's payload */
typedef struct range_t
{
	char *lo;			  /* low payload address */
	char *hi;			  /* high payload address */
	struct range_t *next; /* next list element */
} range_t;

/* Characterizes a single trace operation (allocator request) */
typedef struct
{
	enum
	{
		ALLOC,
		FREE,
		REALLOC
	} type;	/* type of request */
	int index; /* index for free() to use later */
	int size;  /* byte size of alloc/realloc request */
} traceop_t;

/* Holds the information for one trace file*/
typedef struct
{
	int sugg_heapsize;   /* suggested heap size (unused) */
	int num_ids;		 /* number of alloc/realloc ids */
	int num_ops;		 /* number of distinct requests */
	int weight;			 /* weight for this trace (unused) */
	traceop_t *ops;		 /* array of requests */
	char **blocks;		 /* array of ptrs returned by malloc/realloc... */
	size_t *block_sizes; /* ... and a corresponding array of payload sizes */
} trace_t;

typedef struct
{
	/* defined for both libc malloc and student malloc package (mm.c) */
	double ops;  /* number of ops (malloc/free/realloc) in the trace */
	int valid;   /* was the trace processed correctly by the allocator? */
	double secs; /* number of secs needed to run the trace */

	/* defined only for the student malloc package */
	double util; /* space utilization for this trace (always 0 for libc) */

	/* Note: secs and util are only defined if valid is true */
} stats_t;

/*****************************************************************
 * The following routines manipulate the range list, which keeps 
 * track of the extent of every allocated block payload. We use the 
 * range list to detect any overlapping allocated blocks.
 ****************************************************************/

/*
 * add_range - As directed by request opnum in trace tracenum,
 *     we've just called the student's mm_malloc to allocate a block of 
 *     size bytes at addr lo. After checking the block for correctness,
 *     we create a range struct for this block and add it to the range list. 
 */
static int add_range(range_t **ranges, char *lo, int size,
					 int tracenum, int opnum)
{
	char *hi = lo + size - 1;
	range_t *p;
	char msg[MAXLINE];

	assert(size > 0);

	/* Payload addresses must be ALIGNMENT-byte aligned */
	if (!IS_ALIGNED(lo))
	{
		sprintf(msg, "Payload address (%p) not aligned to %d bytes",
				lo, ALIGNMENT);
		malloc_error(tracenum, opnum, msg);
		return 0;
	}

	/* The payload must lie within the extent of the heap */
	if ((lo < (char *)mem_heap_lo()) || (lo > (char *)mem_heap_hi()) ||
		(hi < (char *)mem_heap_lo()) || (hi > (char *)mem_heap_hi()))
	{
		sprintf(msg, "Payload (%p:%p) lies outside heap (%p:%p)",
				lo, hi, mem_heap_lo(), mem_heap_hi());
		malloc_error(tracenum, opnum, msg);
		return 0;
	}

	/* The payload must not overlap any other payloads */
	for (p = *ranges; p != NULL; p = p->next)
	{
		if ((lo >= p->lo && lo <= p->hi) ||
			(hi >= p->lo && hi <= p->hi))
		{
			sprintf(msg, "Payload (%p:%p) overlaps another payload (%p:%p)\n",
					lo, hi, p->lo, p->hi);
			malloc_error(tracenum, opnum, msg);
			return 0;
		}
	}

	/* 
     * Everything looks OK, so remember the extent of this block 
     * by creating a range struct and adding it the range list.
     */
	if ((p = (range_t *)malloc(sizeof(range_t))) == NULL)
		unix_error("malloc error in add_range");
	p->next = *ranges;
	p->lo = lo;
	p->hi = hi;
	*ranges = p;
	return 1;
}

/* 
 * remove_range - Free the range record of block whose payload starts at lo 
 */
static void remove_range(range_t **ranges, char *lo)
{
	range_t *p;
	range_t **prevpp = ranges;
	int size;

	for (p = *ranges; p != NULL; p = p->next)
	{
		if (p->lo == lo)
		{
			*prevpp = p->next;
			size = p->hi - p->lo + 1;
			free(p);
			break;
		}
		prevpp = &(p->next);
	}
}

/*
 * clear_ranges - free all of the range records for a trace 
 */
static void clear_ranges(range_t **ranges)
{
	range_t *p;
	range_t *pnext;

	for (p = *ranges; p != NULL; p = pnext)
	{
		pnext = p->next;
		free(p);
	}
	*ranges = NULL;
}

/**********************************************
 * The following routines manipulate tracefiles
 *********************************************/

/*
 * read_trace - read a trace file and store it in memory
 */
static trace_t *read_trace(char *filename)
{
	FILE *tracefile;
	trace_t *trace;
	char type[MAXLINE];
	char path[MAXLINE];
	unsigned index, size;
	unsigned max_index = 0;
	unsigned op_index;

	
	printf("Reading tracefile: %s\n", filename);

	/* Allocate the trace record */
	if ((trace = (trace_t *)malloc(sizeof(trace_t))) == NULL)
		unix_error("malloc 1 failed in read_trance");

	/* Read the trace file header */
	if ((tracefile = fopen(filename, "r")) == NULL)
	{
		sprintf(msg, "Could not open %s in read_trace", path);
		unix_error(msg);
	}
	fscanf(tracefile, "%d", &(trace->sugg_heapsize)); /* not used */
	fscanf(tracefile, "%d", &(trace->num_ids));
	fscanf(tracefile, "%d", &(trace->num_ops));
	fscanf(tracefile, "%d", &(trace->weight)); /* not used */

	/* We'll store each request line in the trace in this array */
	if ((trace->ops =
			 (traceop_t *)malloc(trace->num_ops * sizeof(traceop_t))) == NULL)
		unix_error("malloc 2 failed in read_trace");

	/* We'll keep an array of pointers to the allocated blocks here... */
	if ((trace->blocks =
			 (char **)malloc(trace->num_ids * sizeof(char *))) == NULL)
		unix_error("malloc 3 failed in read_trace");

	/* ... along with the corresponding byte sizes of each block */
	if ((trace->block_sizes =
			 (size_t *)malloc(trace->num_ids * sizeof(size_t))) == NULL)
		unix_error("malloc 4 failed in read_trace");

	/* read every request line in the trace file */
	index = 0;
	op_index = 0;
	while (fscanf(tracefile, "%s", type) != EOF)
	{
		switch (type[0])
		{
		case 'a':
			fscanf(tracefile, "%u %u", &index, &size);
			trace->ops[op_index].type = ALLOC;
			trace->ops[op_index].index = index;
			trace->ops[op_index].size = size;
			max_index = (index > max_index) ? index : max_index;
			break;
		case 'r':
			fscanf(tracefile, "%u %u", &index, &size);
			trace->ops[op_index].type = REALLOC;
			trace->ops[op_index].index = index;
			trace->ops[op_index].size = size;
			max_index = (index > max_index) ? index : max_index;
			break;
		case 'f':
			fscanf(tracefile, "%ud", &index);
			trace->ops[op_index].type = FREE;
			trace->ops[op_index].index = index;
			break;
		default:
			printf("Bogus type character (%c) in tracefile %s\n",
				   type[0], path);
			exit(1);
		}
		op_index++;
	}
	fclose(tracefile);
	assert(max_index == trace->num_ids - 1);
	assert(trace->num_ops == op_index);

	return trace;
}

/*
 * free_trace - Free the trace record and the three arrays it points
 *              to, all of which were allocated in read_trace().
 */
void free_trace(trace_t *trace)
{
	free(trace->ops); /* free the three arrays... */
	free(trace->blocks);
	free(trace->block_sizes);
	free(trace); /* and the trace record itself... */
}

/**********************************************************************
 * The following functions evaluate the correctness mm malloc packages.
 **********************************************************************/

/*
 * eval_mm_valid - Check the mm malloc package for correctness
 */
static int eval_mm_valid(trace_t *trace, int tracenum, range_t **ranges)
{
	int i, j;
	int index;
	int size;
	int oldsize;
	char *newp;
	char *oldp;
	char *p;

	/* Reset the heap and free any records in the range list */
	mem_reset_brk();
	clear_ranges(ranges);

	/* Call the mm package's init function */
	if (mm_init() < 0)
	{
		malloc_error(tracenum, 0, "mm_init failed.");
		return 0;
	}

	/* Interpret each operation in the trace in order */
	for (i = 0; i < trace->num_ops; i++)
	{
		index = trace->ops[i].index;
		size = trace->ops[i].size;

		switch (trace->ops[i].type)
		{

		case ALLOC: /* mm_malloc */

			/* Call the student's malloc */
			if ((p = mm_malloc(size)) == NULL)
			{
				malloc_error(tracenum, i, "mm_malloc failed.");
				return 0;
			}

			/* 
	     * Test the range of the new block for correctness and add it 
	     * to the range list if OK. The block must be  be aligned properly,
	     * and must not overlap any currently allocated block. 
	     */
			if (add_range(ranges, p, size, tracenum, i) == 0)
				return 0;

			/* ADDED: cgw
	     * fill range with low byte of index.  This will be used later
	     * if we realloc the block and wish to make sure that the old
	     * data was copied to the new block
	     */
			memset(p, index & 0xFF, size);

			/* Remember region */
			trace->blocks[index] = p;
			trace->block_sizes[index] = size;
			break;

		case REALLOC: /* mm_realloc */

			/* Call the student's realloc */
			oldp = trace->blocks[index];
			if ((newp = mm_realloc(oldp, size)) == NULL)
			{
				malloc_error(tracenum, i, "mm_realloc failed.");
				return 0;
			}

			/* Remove the old region from the range list */
			remove_range(ranges, oldp);

			/* Check new block for correctness and add it to range list */
			if (add_range(ranges, newp, size, tracenum, i) == 0)
				return 0;

			/* ADDED: cgw
	     * Make sure that the new block contains the data from the old 
	     * block and then fill in the new block with the low order byte
	     * of the new index
	     */
			oldsize = trace->block_sizes[index];
			if (size < oldsize)
				oldsize = size;
			for (j = 0; j < oldsize; j++)
			{
				if (newp[j] != (index & 0xFF))
				{
					malloc_error(tracenum, i, "mm_realloc did not preserve the "
											  "data from old block");
					return 0;
				}
			}
			memset(newp, index & 0xFF, size);

			/* Remember region */
			trace->blocks[index] = newp;
			trace->block_sizes[index] = size;
			break;

		case FREE: /* mm_free */

			/* Remove region from list and call student's free function */
			p = trace->blocks[index];
			remove_range(ranges, p);
			mm_free(p);
			break;

		default:
			app_error("Nonexistent request type in eval_mm_valid");
		}
	}

	/* As far as we know, this is a valid malloc package */
	return 1;
}

/* 
 * app_error - Report an arbitrary application error
 */
void app_error(char *msg)
{
	printf("%s\n", msg);
	exit(1);
}

/* 
 * unix_error - Report a Unix-style error
 */
void unix_error(char *msg)
{
	printf("%s: %s\n", msg, strerror(errno));
	exit(1);
}

/*
 * malloc_error - Report an error returned by the mm_malloc package
 */
void malloc_error(int tracenum, int opnum, char *msg)
{
	errors++;
	printf("ERROR [trace %d, line %d]: %s\n", tracenum, LINENUM(opnum), msg);
}

int run_trace(char *filename){
	stats_t *mm_stats = NULL;   /* mm (i.e. student) stats for each trace */
    range_t *ranges = NULL;		/* keeps track of block extents for one trace */
    trace_t *trace = NULL;		/* stores a single trace file in memory */

    /*mm_stats = (stats_t *)calloc(num_tracefiles, sizeof(stats_t));*/
	mm_stats = (stats_t *)calloc(1, sizeof(stats_t));
	if (mm_stats == NULL)
		unix_error("mm_stats calloc in main failed");

    /*test the mm malloc*/
    trace = read_trace(filename);
	mm_stats[0].ops = trace->num_ops;
	printf("Checking mm_malloc for correctness\n");
	mm_stats[0].valid = eval_mm_valid(trace, 0, &ranges);
	free_trace(trace);
	if(mm_stats[0].valid)
		return 1;
	else
		return 0;
	
}
int main(int argc, char **argv)
{
	int result = 0;
    printf("\nTesting mm malloc\n");
    mem_init();  /*initialize memory for simulate*/
    result = run_trace("./traces/1.rep");
	if(result == 1)
		printf("***Test1 is passed!\n");
	else
		printf("***Test1 is failed!\n");
	result = run_trace("./traces/2.rep");
	if(result == 1)
		printf("***Test2 is passed!\n");
	else
		printf("***Test2 is failed!\n");
	return 0;
}
